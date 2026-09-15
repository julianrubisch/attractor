# frozen_string_literal: true

require "churn/calculator"

require "attractor/value"

module Attractor
  # calculates churn and complexity
  class BaseCalculator
    attr_reader :type
    attr_accessor :files

    def initialize(file_prefix: "", ignores: "", file_extension: "rb", minimum_churn_count: 3, start_ago: "5y", verbose: false, files: nil)
      @file_prefix = file_prefix
      @file_extension = file_extension
      @minimum_churn_count = minimum_churn_count
      @start_date = Date.today - Attractor::DurationParser.new(start_ago).duration
      @ignores = ignores
      @verbose = verbose
      @files = files
    end

    def calculate
      churn = ::Churn::ChurnCalculator.new(
        file_extension: @file_extension,
        file_prefix: @file_prefix,
        minimum_churn_count: @minimum_churn_count,
        start_date: @start_date,
        ignores: @ignores
      ).report(false)

      changes_by_path = churn[:churn][:changes].each_with_object({}) do |change, hash|
        hash[change[:file_path]] = change
      end

      target_paths = if @files && !@files.empty?
        @files.uniq.select { |file_path| file_path.end_with?(".#{@file_extension}") }
      else
        changes_by_path.keys
      end

      puts "Calculating churn and complexity values for #{target_paths.size} #{type} files" if @verbose

      values = target_paths.filter_map do |file_path|
        change = changes_by_path[file_path]

        if change
          build_value(change) { |c| yield(c) if block_given? }
        elsif @files && !@files.empty? && !File.exist?(file_path)
          missing_value(file_path)
        end
      end

      Cache.persist!

      print "\n\n" if @verbose

      values
    end

    private

    def build_value(change)
      if @files && !@files.empty? && !File.exist?(change[:file_path])
        return missing_value(change[:file_path], churn: change[:times_changed])
      end

      history = git_history_for_file(file_path: change[:file_path])
      commit = history&.first&.first

      cached_value = Cache.read(file_path: change[:file_path])

      if !cached_value.nil? && !cached_value.current_commit.nil? && cached_value.current_commit == commit
        cached_value
      elsif block_given?
        complexity, details = yield(change)

        value = Value.new(file_path: change[:file_path],
          churn: change[:times_changed],
          complexity: complexity,
          details: details,
          history: history)
        Cache.write(file_path: change[:file_path], value: value)
        value
      end
    end

    def missing_value(file_path, churn: 0)
      Value.new(file_path: file_path,
        churn: churn,
        complexity: nil,
        details: [],
        history: git_history_for_file(file_path: file_path))
    end

    def git_history_for_file(file_path:, limit: 10)
      history = `git log --oneline -n #{limit} -- #{file_path}`
      history.split("\n")
        .map do |log_entry|
        log_entry.partition(/\A(\S+)\s/)
          .map(&:strip)
          .reject(&:empty?)
      end
    end
  end
end
