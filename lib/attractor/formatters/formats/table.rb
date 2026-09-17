# frozen_string_literal: true

module Attractor
  module Formatters
    module Formats
      class Table
        def call(report)
          lines = []
          lines << report.title
          lines << ""

          report.metadata.each do |key, value|
            lines << "#{format_key(key)}: #{value}"
          end
          lines << "" unless report.metadata.empty?

          widths = column_widths(report.columns, report.rows)
          lines << format_line(report.columns, widths) { |column| column.to_s }
          lines << format_line(report.columns, widths) { |_column| "-" }

          report.rows.each do |row|
            lines << format_line(report.columns, widths) { |column| row[column].to_s }
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

        def column_widths(columns, rows)
          columns.map do |column|
            values = rows.map { |row| row[column].to_s.length }
            [column.to_s.length, *values].max
          end
        end

        def format_line(columns, widths)
          columns.each_with_index.map do |column, index|
            value = yield(column)
            value.ljust(widths[index])
          end.join("  ")
        end
      end
    end
  end
end
