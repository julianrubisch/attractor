# frozen_string_literal: true

require 'churn/calculator'
require 'flog'

module Attractor
  # calculates churn and complexity
  class Calculator
    def self.calculate
      churn = ::Churn::ChurnCalculator.new(file_extension: 'rb').report(false)
      puts churn.inspect
    end
  end
end
