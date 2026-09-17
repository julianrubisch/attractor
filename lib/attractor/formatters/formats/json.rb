# frozen_string_literal: true

require "json"

module Attractor
  module Formatters
    module Formats
      class JSON
        def call(report)
          report.metadata.merge(
            :title => report.title,
            report.rows_key => rows_for(report),
            :footer => report.footer
          ).compact.to_json
        end

        private

        def rows_for(report)
          return report.rows unless report.group_by

          report.rows.group_by { |row| row[report.group_by] }
        end
      end
    end
  end
end
