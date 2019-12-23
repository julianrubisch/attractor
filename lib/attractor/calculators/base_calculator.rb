# frozen_string_literal: true

require 'churn/calculator'

require 'attractor/value'

module Attractor
  # calculates churn and complexity
  class BaseCalculator
    attr_reader :type

    def initialize(file_prefix: '', file_extension: 'rb', minimum_churn_count: 3)
      @file_prefix = file_prefix
      @file_extension = file_extension
      @minimum_churn_count = minimum_churn_count
    end

    def calculate
      churn = ::Churn::ChurnCalculator.new(
        file_extension: @file_extension,
        file_prefix: @file_prefix,
        minimum_churn_count: @minimum_churn_count,
        start_date: Date.today - 365 * 5
      ).report(false)

      churn[:churn][:changes].map do |change|
        complexity, details = yield(change)
        Value.new(file_path: change[:file_path],
                  churn: change[:times_changed],
                  complexity: complexity,
                  details: details,
                  history: git_history_for_file(file_path: change[:file_path]))
      end
    end

    private

    def git_history_for_file(file_path:, limit: 10)
      history = `git log --oneline -n #{limit} -- #{file_path}`
      history.split("\n")
             .map do |log_entry|
        log_entry.partition(/\A(\S+)\s/)
                 .map(&:strip)
                 .reject(&:empty?)
      end
    end
  end
end
