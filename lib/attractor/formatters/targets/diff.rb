# frozen_string_literal: true

require "attractor/formatters/report"

module Attractor
  module Formatters
    module Targets
      class Diff
        def call(data)
          Report.new(
            title: "Complexity diff between #{data[:base_ref]} and #{data[:head_ref]}",
            metadata: {
              total_score_base: data[:total_score_base],
              total_score_head: data[:total_score_head],
              trend: data[:trend]
            },
            columns: %i[file_path complexity_base complexity_head delta churn score_head refactor_base refactor_head],
            rows: data[:files],
            rows_key: :files
          )
        end
      end
    end
  end
end
