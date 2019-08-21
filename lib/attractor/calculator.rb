# frozen_string_literal: true

require 'churn/calculator'
require 'date'
require 'flog'
require 'path_expander'

require 'attractor/value'

module Attractor
  # calculates churn and complexity
  class Calculator
    def self.calculate(file_extension: 'rb', minimum_churn_count: 3)
      churn = ::Churn::ChurnCalculator.new(
        file_extension: file_extension,
        minimum_churn_count: minimum_churn_count,
        start_date: Date.today - 365 * 5
      ).report(false)

      churn[:churn][:changes].map do |change|
        flogger = Flog.new(all: true)
        flogger.flog(change[:file_path])
        complexity = flogger.total_score
        Value.new(file_path: change[:file_path], churn: change[:times_changed], complexity: complexity)
      end
    end

    def self.output_console
      values = calculate
      puts values.map(&:to_s)
    end

    def self.report

    end
  end
end
