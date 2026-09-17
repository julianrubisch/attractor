# frozen_string_literal: true

require "csv"

module Attractor
  module Formatters
    module Formats
      class CSV
        def call(report)
          ::CSV.generate do |csv|
            csv << report.columns
            report.rows.each do |row|
              csv << report.columns.map { |column| row[column] }
            end
          end
        end
      end
    end
  end
end
