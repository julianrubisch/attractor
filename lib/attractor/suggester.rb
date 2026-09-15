# frozen_string_literal: true

module Attractor
  # makes suggestions for refactorings
  class Suggester
    attr_accessor :values

    def initialize(values = [])
      @values = values
    end

    def suggest(threshold = 95)
      scored_values = @values.reject { |value| value.score.nil? }
      return [] if scored_values.empty?

      products = scored_values.map(&:score)
      products.extend(DescriptiveStatistics)
      quantile = products.percentile(threshold.to_i)

      scored_values.select { |val| val.score > quantile }
        .sort_by { |val| val.score }.reverse
    end
  end
end
