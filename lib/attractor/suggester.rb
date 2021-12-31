# frozen_string_literal: true

module Attractor
  # makes suggestions for refactorings
  class Suggester
    attr_accessor :values

    def initialize(values)
      @values = values || []
    end

    def suggest(threshold = 95)
      products = @values.map(&:score)
      products.extend(DescriptiveStatistics)
      quantile = products.percentile(threshold.to_i)

      @values.select { |val| val.score > quantile }
        .sort_by { |val| val.score }.reverse
    end
  end
end
