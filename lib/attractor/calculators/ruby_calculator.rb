# frozen_string_literal: true

require 'flog'

module Attractor
  class RubyCalculator < BaseCalculator
    def initialize(file_prefix: '', minimum_churn_count: 3, start_ago: 365 * 5)
      super(file_prefix: file_prefix, file_extension: 'rb', minimum_churn_count: minimum_churn_count, start_ago: start_ago)
      @type = "Ruby"
    end

    def calculate
      super do |change|
        flogger = Flog.new(all: true)
        flogger.flog(change[:file_path])
        complexity = flogger.total_score
        details = flogger.totals
        [complexity, details]
      end
    end
  end
end
