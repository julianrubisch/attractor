# frozen_string_literal: true

require "attractor/formatters"

module Attractor
  # console reporter
  class ConsoleReporter < BaseReporter
    def initialize(format:, **other)
      super(**other)
      @formatter = Attractor::Formatters::Formatter.new(target: :console, format: format)
    end

    def report
      super
      puts @formatter.call(@calculators)
    end
  end
end
