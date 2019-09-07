# frozen_string_literal: true

require 'churn/calculator'
require 'csv'
require 'date'
require 'flog'
require 'listen'

require 'attractor/value'

module Attractor
  # calculates churn and complexity
  class Calculator
    def initialize(file_prefix: '')
      @file_prefix = file_prefix
      @file_extension = 'rb'
      @minimum_churn_count = 3
    end

    def calculate
      churn = ::Churn::ChurnCalculator.new(
        file_extension: @file_extension,
        file_prefix: @file_prefix,
        minimum_churn_count: @minimum_churn_count,
        start_date: Date.today - 365 * 5
      ).report(false)

      churn[:churn][:changes].map do |change|
        flogger = Flog.new(all: true)
        flogger.flog(change[:file_path])
        complexity = flogger.total_score
        Value.new(file_path: change[:file_path], churn: change[:times_changed], complexity: complexity)
      end
    end

    def self.watch(file_prefix: '')
      listener = Listen.to(file_prefix) do |_modified, _added, _removed|
        puts "modified #{_modified}"
        puts "added #{_added}"
        puts "removed #{_removed}"
      end
      listener.start
      sleep
    end
  end
end
