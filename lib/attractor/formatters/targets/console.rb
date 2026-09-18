# frozen_string_literal: true

require "attractor/formatters/report"

module Attractor
  module Formatters
    module Targets
      class Console
        def call(calculators)
          rows = []
          footer_lines = []

          calculators.each do |type, calc|
            values = calc.calculate
            suggester = Suggester.new(values)
            refactor_files = suggester.suggest.map(&:file_path)

            values.each do |value|
              rows << {
                type: type,
                file_path: value.file_path,
                score: value.score,
                complexity: value.complexity,
                churn: value.churn,
                refactor: refactor_files.include?(value.file_path),
                details: value.details,
                history: value.history
              }
            end

            footer_lines << "Suggestions for refactorings:"
            footer_lines += refactor_files unless refactor_files.empty?
          end

          Report.new(
            title: "Calculated churn and complexity",
            metadata: {schema: 2},
            columns: %i[file_path score complexity churn type refactor],
            rows: rows,
            footer: footer_lines.empty? ? nil : footer_lines.join("\n"),
            group_by: :type
          )
        end
      end
    end
  end
end
