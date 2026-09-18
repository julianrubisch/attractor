# frozen_string_literal: true

require "attractor/formatters/report"

module Attractor
  module Formatters
    module Targets
      class Diff
        def call(data)
          files = data[:files]

          Report.new(
            title: "Attractor: #{data[:base_ref]}..#{data[:head_ref]}",
            columns: %i[file_path complexity_base complexity_head delta churn score_head refactor_base refactor_head],
            rows: files,
            rows_key: :files,
            sections: [
              {title: "Stats", columns: %i[language score trend], rows: stats_rows(files)},
              {title: "Trends", columns: ["", :most_improved, :largest_declines], rows: trends_rows(files)},
              {title: "To-dos", columns: ["", :new_refactoring_candidates, :refactored], rows: todos_rows(files)}
            ],
            collapsed_table: true
          )
        end

        private

        def stats_rows(files)
          rows_by_type(files).map do |type, rows|
            total_base = rows.sum { |row| row[:score_base].to_f }
            total_head = rows.sum { |row| row[:score_head].to_f }
            trend = total_head - total_base
            percent = total_base.zero? ? 0.0 : (trend / total_base * 100)

            {
              language: type,
              score: "#{format("%.1f", total_head)} (from #{format("%.1f", total_base)})",
              trend: trend.zero? ? "0.0%" : "#{trend_emoji(trend)} #{format("%+.1f", percent)}%"
            }
          end
        end

        def trends_rows(files)
          rows_by_type(files).map do |type, rows|
            improved = rows.select { |row| row[:delta].negative? }.first(5)
            declined = rows.select { |row| row[:delta].positive? }.first(5)

            {
              "" => type,
              :most_improved => improved.empty? ? "none" : improved.map { |row| "#{row[:file_path]} (#{format("%.1f", row[:delta])})" }.join(", "),
              :largest_declines => declined.empty? ? "none" : declined.map { |row| "#{row[:file_path]} (#{format("%+.1f", row[:delta])})" }.join(", ")
            }
          end
        end

        def todos_rows(files)
          rows_by_type(files).map do |type, rows|
            flipped = rows.select { |row| row[:refactor_base] != row[:refactor_head] }
            new_candidates = flipped.select { |row| row[:refactor_head] }
            refactored = flipped.reject { |row| row[:refactor_head] }

            {
              "" => type,
              :new_refactoring_candidates => new_candidates.empty? ? "none" : new_candidates.map { |row| row[:file_path] }.join(", "),
              :refactored => refactored.empty? ? "none" : refactored.map { |row| row[:file_path] }.join(", ")
            }
          end
        end

        def rows_by_type(files)
          files.reject { |row| row[:type].nil? }.group_by { |row| row[:type] }
        end

        def trend_emoji(trend)
          trend.positive? ? "📈" : "📉"
        end
      end
    end
  end
end
