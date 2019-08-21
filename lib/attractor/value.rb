# frozen_string_literal: true

module Attractor
  # holds a churn/complexity value
  class Value
    attr_reader :file_path, :churn, :complexity

    def initialize(file_path: '', churn: 1, complexity: 0)
      @file_path = file_path
      @churn = churn
      @complexity = complexity
    end

    def to_s
      format('%-64s%8.1f%8i', @file_path, @complexity, @churn)
    end

    def to_h
      { file_path: file_path, x: churn, y: complexity }
    end

    def to_json(_opt)
      to_h.to_json
    end
  end
end
