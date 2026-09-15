# frozen_string_literal: true

require "json"

module Attractor
  # Reporter for complexity deltas between two git refs
  class DiffReporter
    def initialize(format:)
      @formatter = case format.to_sym
      when :json
        JSONFormatter.new
      when :markdown
        MarkdownFormatter.new
      else
        TableFormatter.new
      end
    end

    def report(data)
      @formatter.call(data)
    end

    class TableFormatter
      def call(data)
        puts "Complexity diff between #{data[:base_ref]} and #{data[:head_ref]}"
        puts
        puts "Total score: #{format_score(data[:total_score_base])} → #{format_score(data[:total_score_head])} (#{format_trend(data[:trend])})"
        puts
        puts header
        puts separator

        data[:files].each do |row|
          puts format_row(row)
        end
      end

      private

      def header
        format_line("file_path", "c_base", "c_head", "delta", "churn", "score_head", "refactor_base", "refactor_head")
      end

      def separator
        "-" * 110
      end

      def format_line(file_path, base, head, delta, churn, score, refactor_base, refactor_head)
        sprintf("%-48s %10s %10s %10s %8s %12s %14s %15s",
          file_path, base, head, delta, churn, score, refactor_base, refactor_head)
      end

      def format_row(row)
        format_line(
          row[:file_path],
          format_complexity(row[:complexity_base]),
          format_complexity(row[:complexity_head]),
          format_float(row[:delta]),
          format_churn(row[:churn]),
          format_score(row[:score_head]),
          row[:refactor_base],
          row[:refactor_head]
        )
      end

      def format_complexity(value)
        value.nil? ? "n/a" : format("%.1f", value)
      end

      def format_float(value)
        format("%.1f", value)
      end

      def format_churn(value)
        value.nil? ? "n/a" : value.to_s
      end

      def format_score(value)
        value.nil? ? "n/a" : value.to_s
      end

      def format_trend(value)
        return "flat" if value.zero?

        value.positive? ? "↑ #{value}" : "↓ #{value.abs}"
      end
    end

    class JSONFormatter
      def call(data)
        puts data.to_json
      end
    end

    class MarkdownFormatter
      def call(data)
        puts "# Complexity diff between `#{data[:base_ref]}` and `#{data[:head_ref]}`"
        puts
        puts "**Total score:** `#{data[:total_score_base]}` → `#{data[:total_score_head]}` (#{format_trend(data[:trend])})"
        puts
        puts "| file_path | complexity_base | complexity_head | delta | churn | score_head | refactor_base | refactor_head |"
        puts "|-----------|----------------:|----------------:|------:|------:|-----------:|:-------------:|:-------------:|"

        data[:files].each do |row|
          puts "| #{row[:file_path]} | #{format_complexity(row[:complexity_base])} | #{format_complexity(row[:complexity_head])} | #{format_float(row[:delta])} | #{format_churn(row[:churn])} | #{format_score(row[:score_head])} | #{row[:refactor_base]} | #{row[:refactor_head]} |"
        end
      end

      private

      def format_complexity(value)
        value.nil? ? "n/a" : "%.1f" % value
      end

      def format_float(value)
        "%.1f" % value
      end

      def format_churn(value)
        value.nil? ? "n/a" : value.to_s
      end

      def format_score(value)
        value.nil? ? "n/a" : value.to_s
      end

      def format_trend(value)
        return "flat" if value.zero?

        value.positive? ? "↑ #{value}" : "↓ #{value.abs}"
      end
    end
  end
end
