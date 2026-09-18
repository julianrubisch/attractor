# frozen_string_literal: true

module Attractor
  module Formatters
    module Formats
      class Markdown
        def call(report)
          lines = []
          lines << "# #{report.title}"
          lines << ""

          report.metadata.each do |key, value|
            lines << "**#{format_key(key)}:** #{value}"
          end
          lines << "" unless report.metadata.empty?

          lines << "| #{report.columns.join(" | ")} |"
          lines << "| #{report.columns.map { |column| "-" * column.to_s.length }.join(" | ")} |"

          report.rows.each do |row|
            lines << "| #{report.columns.map { |column| row[column] }.join(" | ")} |"
          end

          if report.footer
            lines << ""
            lines << report.footer
          end

          lines.join("\n")
        end

        private

        def format_key(key)
          key.to_s.split("_").map(&:capitalize).join(" ")
        end
      end
    end
  end
end
