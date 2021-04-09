# frozen_string_literal: true

require "json"

module Attractor
  # holds a churn/complexity value
  class Value
    attr_reader :file_path, :churn, :complexity, :details, :history

    def initialize(file_path: "", churn: 1, complexity: 0, details: [], history: [])
      @file_path = file_path
      @churn = churn
      @complexity = complexity
      @details = details
      @history = history
    end

    def current_commit
      history&.first&.first
    end

    def to_s
      format("%-64s%8.1f%8i", @file_path, @complexity, @churn)
    end

    def to_h
      {file_path: file_path, x: churn, y: complexity, details: details, history: history}
    end

    def to_json(_opt)
      to_h.to_json
    end
  end
end
