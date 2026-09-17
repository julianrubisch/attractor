# frozen_string_literal: true

require "attractor/formatters/format_helpers"

module Attractor
  module Formatters
    class DiffMarkdownFormatter
      include FormatHelpers

      def call(data)
        lines = []
        lines << "# Complexity diff between `#{data[:base_ref]}` and `#{data[:head_ref]}`"
        lines << ""
        lines << "**Total score:** `#{data[:total_score_base]}` → `#{data[:total_score_head]}` (#{format_trend(data[:trend])})"
        lines << ""
        lines << "| file_path | complexity_base | complexity_head | delta | churn | score_head | refactor_base | refactor_head |"
        lines << "|-----------|----------------:|----------------:|------:|------:|-----------:|:-------------:|:-------------:|"

        data[:files].each do |row|
          lines << format_row(row)
        end

        lines.join("\n")
      end

      private

      def format_row(row)
        "| #{row[:file_path]} | #{format_complexity(row[:complexity_base])} | #{format_complexity(row[:complexity_head])} | #{format_float(row[:delta])} | #{format_churn(row[:churn])} | #{format_score(row[:score_head])} | #{row[:refactor_base]} | #{row[:refactor_head]} |"
      end
    end
  end
end
