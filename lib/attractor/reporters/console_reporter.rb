# frozen_string_literal: true

module Attractor
  # console reporter
  class ConsoleReporter < BaseReporter
    def report
      super
      puts "Calculated churn and complexity"
      puts
      puts "file_path#{" " * 53}complexity   churn"
      puts "-" * 80

      @calculators.each do |calc|
        # e.g. ['js', JsCalculator']
        puts calc.last.type

        values = calc.last.calculate
        suggester = Suggester.new(values)

        puts values&.map(&:to_s)
        puts
        puts "Suggestions for refactorings:"
        suggester.suggest&.each { |sug| puts sug.file_path }
        puts
      end
    end
  end
end
