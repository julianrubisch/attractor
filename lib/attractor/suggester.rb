# frozen_string_literal: true

module Attractor
  # makes suggestions for refactorings
  class Suggester
    def initialize(values)
      @values = values
    end

    def suggest
      products = @values.map { |val| val.churn * val.complexity }
      products.extend(DescriptiveStatistics)
      top_95_quantile = products.percentile(95)

      @values.select { |val| val.churn * val.complexity > top_95_quantile }
    end
  end
end
