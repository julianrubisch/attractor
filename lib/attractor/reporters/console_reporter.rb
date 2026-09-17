# frozen_string_literal: true

require "attractor/formatters"

module Attractor
  # console reporter
  class ConsoleReporter < BaseReporter
    def initialize(format:, **other)
      super(**other)
      @formatter = Attractor::Formatters.console(format)
    end

    def report
      super
      data = @calculators.map do |type, calc|
        values = calc.calculate
        suggester = Suggester.new(values)
        refactor_files = suggester.suggest.map(&:file_path)

        {type: type, values: values, refactor_files: refactor_files}
      end

      puts @formatter.call(data)
    end
  end
end
