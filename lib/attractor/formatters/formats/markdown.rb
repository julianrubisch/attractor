# frozen_string_literal: true

module Attractor
  module Formatters
    module Formats
      class Markdown
        def call(report)
          lines = []
          lines << "#{title_prefix(report)} #{report.title}"
          lines << ""

          report.metadata.each do |key, value|
            lines << "**#{format_key(key)}:** #{value}"
          end
          lines << "" unless report.metadata.empty?

          report.sections.each do |section|
            lines << "### #{section[:title]}"
            lines << ""
            lines += render_table(section[:columns], section[:rows])
            lines << ""
          end

          if report.collapsed_table
            lines << "<details>"
            lines << "<summary>All files</summary>"
            lines << ""
          end

          lines += render_table(report.columns, report.rows)

          if report.collapsed_table
            lines << ""
            lines << "</details>"
          end

          if report.footer
            lines << ""
            lines << report.footer
          end

          lines.join("\n")
        end

        private

        def render_table(columns, rows)
          return [] if columns.empty?

          lines = []
          lines << "| #{columns.join(" | ")} |"
          lines << "| #{columns.map { |column| "-" * column.to_s.length }.join(" | ")} |"

          rows.each do |row|
            lines << "| #{columns.map { |column| format_cell(column, row) }.join(" | ")} |"
          end

          lines
        end

        def format_cell(column, row)
          value = row[column]

          if column == :delta
            return "new" if row[:complexity_base].nil? && !row[:complexity_head].nil?
            return "deleted" if row[:complexity_head].nil? && !row[:complexity_base].nil?
          end

          value
        end

        def title_prefix(report)
          (report.sections.any? || report.collapsed_table) ? "##" : "#"
        end

        def format_key(key)
          key.to_s.split("_").map(&:capitalize).join(" ")
        end
      end
    end
  end
end
