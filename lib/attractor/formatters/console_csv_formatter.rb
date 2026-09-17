# frozen_string_literal: true

require "csv"

module Attractor
  module Formatters
    class ConsoleCSVFormatter
      def call(data)
        CSV.generate do |csv|
          csv << %w[file_path score complexity churn type refactor]

          data.each do |entry|
            entry[:values].each do |value|
              csv << [value.file_path, value.score, value.complexity, value.churn, entry[:type], entry[:refactor_files].include?(value.file_path)]
            end
          end
        end
      end
    end
  end
end
