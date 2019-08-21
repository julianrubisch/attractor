# frozen_string_literal: true

module Attractor
  class Value
    attr_reader :file_path, :churn, :complexity

    def initialize(file_path: '', churn: 1, complexity: 0)
      @file_path = file_path
      @churn = churn
      @complexity = complexity
    end

    def to_s
      "#{file_path}: churn #{@churn}, complexity: #{@complexity}"
    end
  end
end
