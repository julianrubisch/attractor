# frozen_string_literal: true

require "attractor/formatters/base_formatter"

module Attractor
  module Formatters
    class DiffTableFormatter < BaseFormatter
      def call(data)
        lines = []
        lines << "Complexity diff between #{data[:base_ref]} and #{data[:head_ref]}"
        lines << ""
        lines << "Total score: #{format_score(data[:total_score_base])} → #{format_score(data[:total_score_head])} (#{format_trend(data[:trend])})"
        lines << ""
        lines << header
        lines << separator

        data[:files].each do |row|
          lines << format_row(row)
        end

        lines.join("\n")
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
    end
  end
end
