# frozen_string_literal: true

require "fileutils"
require "tmpdir"

require "attractor"

module Attractor
  # Calculates complexity deltas between two git refs using temporary worktrees
  class DiffCalculator
    attr_reader :base_ref, :head_ref, :files, :options

    def initialize(base_ref:, head_ref:, files: nil, **options)
      @base_ref = base_ref
      @head_ref = head_ref
      @files = files
      @options = options
    end

    def calculate
      validate_refs!
      file_list = @files || default_files

      base_dir = Dir.mktmpdir("attractor-diff-base-")
      head_dir = Dir.mktmpdir("attractor-diff-head-")

      create_worktree(base_dir, @base_ref)
      create_worktree(head_dir, @head_ref)

      base_values = calculate_in_worktree(base_dir, file_list)
      head_values = calculate_in_worktree(head_dir, file_list)

      Attractor::Cache.reset!
      build_diff(base_values, head_values, file_list)
    ensure
      remove_worktree(base_dir) if base_dir
      remove_worktree(head_dir) if head_dir
      FileUtils.rm_rf(base_dir) if base_dir
      FileUtils.rm_rf(head_dir) if head_dir
    end

    private

    def validate_refs!
      raise ArgumentError, "base_ref is required" if @base_ref.nil? || @base_ref.empty?
      raise ArgumentError, "head_ref is required" if @head_ref.nil? || @head_ref.empty?

      rev_parse(@base_ref)
      rev_parse(@head_ref)
    end

    def rev_parse(ref)
      output = `git rev-parse --verify #{ref}`
      raise ArgumentError, "Invalid git ref: #{ref}" unless $CHILD_STATUS.success?

      output.strip
    end

    def default_files
      output = `git diff --name-only #{@base_ref}...#{@head_ref}`
      output.lines(chomp: true).reject(&:empty?)
    end

    def create_worktree(path, ref)
      success = system("git", "worktree", "add", "-f", path, ref, out: File::NULL, err: File::NULL)
      raise "Failed to create git worktree for #{ref} at #{path}" unless success
    end

    def remove_worktree(path)
      system("git", "worktree", "remove", "-f", path, out: File::NULL, err: File::NULL)
    end

    def calculate_in_worktree(path, files)
      Attractor::Cache.reset!
      Dir.chdir(path) do
        Attractor.calculators_for_type(@options[:type],
          file_prefix: @options[:file_prefix],
          minimum_churn_count: @options[:minimum_churn_count],
          ignores: @options[:ignores],
          start_ago: @options[:start_ago],
          verbose: @options[:verbose],
          files: files).transform_values(&:calculate)
      end
    end

    def build_diff(base_values, head_values, files)
      base_by_path = flatten_values(base_values)
      head_by_path = flatten_values(head_values)

      base_refactor_files = refactor_files(base_by_path.values)
      head_refactor_files = refactor_files(head_by_path.values)

      rows = files.uniq.map do |file_path|
        build_row(file_path, base_by_path[file_path], head_by_path[file_path], base_refactor_files, head_refactor_files)
      end

      rows.sort_by! { |row| -row[:delta].abs }

      total_score_base = base_by_path.values.sum { |value| value.score || 0 }
      total_score_head = head_by_path.values.sum { |value| value.score || 0 }

      {
        base_ref: @base_ref,
        head_ref: @head_ref,
        total_score_base: total_score_base,
        total_score_head: total_score_head,
        trend: total_score_head - total_score_base,
        files: rows
      }
    end

    def flatten_values(values_by_type)
      values_by_type.values.flatten.compact.each_with_object({}) do |value, hash|
        hash[value.file_path] = value
      end
    end

    def refactor_files(values)
      Suggester.new(values).suggest.map(&:file_path)
    end

    def build_row(file_path, base_value, head_value, base_refactor_files, head_refactor_files)
      complexity_base = base_value&.complexity
      complexity_head = head_value&.complexity

      delta = if complexity_base.nil? && complexity_head.nil?
        0
      elsif complexity_base.nil?
        complexity_head.to_f
      elsif complexity_head.nil?
        -complexity_base.to_f
      else
        complexity_head.to_f - complexity_base.to_f
      end

      {
        file_path: file_path,
        complexity_base: complexity_base,
        complexity_head: complexity_head,
        delta: delta,
        churn: head_value&.churn,
        score_head: head_value&.score,
        refactor_base: base_refactor_files.include?(file_path),
        refactor_head: head_refactor_files.include?(file_path),
        details_base: base_value&.details,
        details_head: head_value&.details
      }
    end
  end
end
