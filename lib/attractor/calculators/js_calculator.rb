# frozen_string_literal: true

module Attractor
  class JsCalculator < BaseCalculator
    def initialize(file_prefix: '', minimum_churn_count: 3, start_ago: 365 * 5)
      super(file_prefix: file_prefix, file_extension: '(js|jsx)', minimum_churn_count: minimum_churn_count, start_ago: start_ago)
      @type = "JavaScript"
    end

    def calculate
      super do |change|
        complexity, details = JSON.parse(`node #{__dir__}/../../../dist/calculator.bundle.js #{Dir.pwd}/#{change[:file_path]}`)

        [complexity, details]
      end
    end
  end
end
