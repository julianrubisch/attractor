# frozen_string_literal: true

require "attractor/formatters/formatter"
require "attractor/formatters/targets/console"
require "attractor/formatters/formats/json"
require "attractor/formatters/formats/table"
require "attractor/formatters/formats/csv"
require "attractor/formatters/formats/markdown"
require "attractor/formatters/format_strategy"

module Attractor
  # console reporter
  class ConsoleReporter < BaseReporter
    include Attractor::Formatters::FormatStrategy

    def initialize(format:, **other)
      super(**other)
      @formatter = Attractor::Formatters::Formatter.new(
        target: Attractor::Formatters::Targets::Console.new,
        format: format_strategy(format)
      )
    end

    def report
      super
      puts @formatter.call(@calculators)
    end
  end
end
