# frozen_string_literal: true

require 'churn/calculator'
require 'flog'

require 'attractor/value'

module Attractor
  # calculates churn and complexity
  class Calculator
    def self.calculate(file_extension: 'rb', minimum_churn_count: 3)
      churn = ::Churn::ChurnCalculator.new(
        file_extension: file_extension,
        minimum_churn_count: minimum_churn_count
      ).report(false)

      values = churn[:churn][:changes].map do |change|
        Value.new(file_path: change[:file_path], churn: change[:times_changed])
      end

      puts values.inspect
    end
  end
end
