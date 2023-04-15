# frozen_string_literal: true

require "churn/calculator"

require "attractor/value"

module Attractor
  # calculates churn and complexity
  class BaseCalculator
    attr_reader :type

    def initialize(file_prefix: "", ignores: "", file_extension: "rb", minimum_churn_count: 3, start_ago: "5y", verbose: false)
      @file_prefix = file_prefix
      @file_extension = file_extension
      @minimum_churn_count = minimum_churn_count
      @start_date = Date.today - Attractor::DurationParser.new(start_ago).duration
      @ignores = ignores
      @verbose = verbose
    end

    def calculate
      churn = ::Churn::ChurnCalculator.new(
        file_extension: @file_extension,
        file_prefix: @file_prefix,
        minimum_churn_count: @minimum_churn_count,
        start_date: @start_date,
        ignores: @ignores
      ).report(false)

      puts "Calculating churn and complexity values for #{churn[:churn][:changes].size} #{type} files" if @verbose

      values = churn[:churn][:changes].map do |change|
        history = git_history_for_file(file_path: change[:file_path])
        commit = history&.first&.first

        cached_value = Cache.read(file_path: change[:file_path])

        if !cached_value.nil? && !cached_value.current_commit.nil? && cached_value.current_commit == commit
          value = cached_value
        else
          complexity, details = yield(change)

          value = Value.new(file_path: change[:file_path],
            churn: change[:times_changed],
            complexity: complexity,
            details: details,
            history: history)
          Cache.write(file_path: change[:file_path], value: value)
        end

        print "." if @verbose
        value
      end

      Cache.persist!

      print "\n\n" if @verbose

      values
    end

    private

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
