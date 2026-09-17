# frozen_string_literal: true

require "attractor/formatters/formatter"
require "attractor/formatters/targets/console"
require "attractor/formatters/formats/json"
require "attractor/formatters/formats/table"
require "attractor/formatters/formats/csv"

module Attractor
  # console reporter
  class ConsoleReporter < BaseReporter
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

    private

    def format_strategy(format)
      case format.to_sym
      when :csv then Attractor::Formatters::Formats::CSV.new
      when :json then Attractor::Formatters::Formats::JSON.new
      else Attractor::Formatters::Formats::Table.new
      end
    end
  end
end
