# frozen_string_literal: true

require "json"
require "attractor/formatters/base_formatter"

module Attractor
  module Formatters
    class ConsoleJSONFormatter < BaseFormatter
      def call(data)
        result = data.map do |entry|
          [
            entry[:type],
            entry[:values].map do |value|
              {
                file_path: value.file_path,
                score: value.score,
                complexity: value.complexity,
                churn: value.churn,
                refactor: entry[:refactor_files].include?(value.file_path),
                details: value.details,
                history: value.history
              }
            end
          ]
        end

        result.to_h.to_json
      end
    end
  end
end
