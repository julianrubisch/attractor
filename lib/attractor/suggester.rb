# frozen_string_literal: true

module Attractor
  # makes suggestions for refactorings
  class Suggester
    def initialize(values)
      @values = values
    end

    def suggest(threshold = 95)
      products = @values.map { |val| val.churn * val.complexity }
      products.extend(DescriptiveStatistics)
      quantile = products.percentile(threshold.to_i)

      @values.select { |val| val.churn * val.complexity > quantile }
             .sort_by { |val| val.churn * val.complexity }.reverse
    end
  end
end
