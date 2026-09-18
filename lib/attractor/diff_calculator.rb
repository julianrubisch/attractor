# frozen_string_literal: true

require "attractor"
require "attractor/git"

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
      file_list = @files || Git.diff_files(@base_ref, @head_ref)

      base_worktree = Git::Worktree.new(@base_ref).checkout
      head_worktree = Git::Worktree.new(@head_ref).checkout

      base_values = calculate_in_worktree(base_worktree, file_list)
      head_values = calculate_in_worktree(head_worktree, file_list)

      Attractor::Cache.reset!
      build_diff(base_values, head_values, file_list)
    ensure
      base_worktree&.cleanup
      head_worktree&.cleanup
    end

    private

    def validate_refs!
      case [@base_ref, @head_ref]
      in [nil | "", _]
        raise ArgumentError, "base_ref is required"
      in [_, nil | ""]
        raise ArgumentError, "head_ref is required"
      else
        Git.validate_ref!(@base_ref)
        Git.validate_ref!(@head_ref)
      end
    end

    def calculate_in_worktree(worktree, files)
      Attractor::Cache.reset!
      worktree.chdir do
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
      file_types = build_file_types(base_values, head_values)

      base_refactor_files = refactor_files(base_by_path.values)
      head_refactor_files = refactor_files(head_by_path.values)

      rows = files.uniq.map do |file_path|
        build_row(file_path, base_by_path[file_path], head_by_path[file_path], base_refactor_files, head_refactor_files, file_types[file_path])
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
      values_by_type.each_with_object({}) do |(_type, values), hash|
        Array(values).compact.each do |value|
          hash[value.file_path] = value
        end
      end
    end

    def build_file_types(base_values, head_values)
      [base_values, head_values].each_with_object({}) do |values_by_type, hash|
        values_by_type.each do |type, values|
          Array(values).compact.each do |value|
            hash[value.file_path] ||= type
          end
        end
      end
    end

    def refactor_files(values)
      Suggester.new(values).suggest.map(&:file_path)
    end

    def build_row(file_path, base_value, head_value, base_refactor_files, head_refactor_files, type)
      complexity_base = base_value&.complexity
      complexity_head = head_value&.complexity

      delta = case [complexity_base, complexity_head]
      in [nil, nil]
        0
      in [nil, head]
        head.to_f
      in [base, nil]
        -base.to_f
      in [base, head]
        head.to_f - base.to_f
      end

      {
        file_path: file_path,
        type: type,
        complexity_base: complexity_base,
        complexity_head: complexity_head,
        delta: delta,
        churn: head_value&.churn,
        score_base: base_value&.score,
        score_head: head_value&.score,
        refactor_base: base_refactor_files.include?(file_path),
        refactor_head: head_refactor_files.include?(file_path),
        details_base: base_value&.details,
        details_head: head_value&.details
      }
    end
  end
end
