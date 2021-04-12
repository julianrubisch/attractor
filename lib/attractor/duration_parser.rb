# frozen_string_literal: true

module Attractor
  # converts a duration string into an amount of days
  class DurationParser
    TOKENS = {
      "d" => 1,
      "w" => 7,
      "m" => 30,
      "y" => 365
    }.freeze

    attr_reader :duration

    def initialize(input)
      @input = input
      @duration = @input.is_a?(Numeric) ? @input : 0
      return if @duration > 0

      parse
    end

    def parse
      @input.scan(/(\d+)(\w)/).each do |amount, measure|
        @duration += amount.to_i * TOKENS[measure]
      end
    end
  end
end
