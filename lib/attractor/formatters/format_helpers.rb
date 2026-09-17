# frozen_string_literal: true

module Attractor
  module Formatters
    module FormatHelpers
      private

      def format_complexity(value)
        value.nil? ? "n/a" : format("%.1f", value)
      end

      def format_churn(value)
        value.nil? ? "n/a" : value.to_s
      end

      def format_score(value)
        value.nil? ? "n/a" : value.to_s
      end

      def format_float(value)
        format("%.1f", value)
      end

      def format_trend(value)
        return "flat" if value.zero?

        value.positive? ? "↑ #{value}" : "↓ #{value.abs}"
      end
    end
  end
end
