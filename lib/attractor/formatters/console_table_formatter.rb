# frozen_string_literal: true

require "attractor/formatters/base_formatter"

module Attractor
  module Formatters
    class ConsoleTableFormatter < BaseFormatter
      def call(data)
        lines = []
        lines << "Calculated churn and complexity"
        lines << ""
        lines << "file_path#{" " * 53}complexity   churn"
        lines << "-" * 80

        data.each do |entry|
          lines << entry[:type]
          lines += entry[:values]&.map(&:to_s)
          lines << ""
          lines << "Suggestions for refactorings:"
          lines += entry[:refactor_files]
          lines << ""
        end

        lines.join("\n")
      end
    end
  end
end
