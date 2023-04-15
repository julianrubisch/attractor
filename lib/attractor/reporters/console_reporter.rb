# frozen_string_literal: true

module Attractor
  # console reporter
  class ConsoleReporter < BaseReporter
    class TableFormatter
      def call(calculators)
        puts "Calculated churn and complexity"
        puts
        puts "file_path#{" " * 53}complexity   churn"
        puts "-" * 80

        calculators.each do |calc|
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

    class CSVFormatter
      def call(calculators)
        require "csv"

        result = CSV.generate do |csv|
          csv << %w[file_path score complexity churn type refactor]

          calculators.each do |calc|
            type = calc.last.type
            values = calc.last.calculate
            suggester = Suggester.new(values)
            to_be_refactored = suggester.suggest.map(&:file_path)

            values.each do |value|
              csv << [value.file_path, value.score, value.complexity, value.churn, type, to_be_refactored.include?(value.file_path)]
            end
          end
        end

        puts result
      end
    end

    class JSONFormatter
      def call(calculators)
        result = calculators.map do |calc|
          type = calc.last.type
          values = calc.last.calculate
          suggester = Suggester.new(values)
          to_be_refactored = suggester.suggest.map(&:file_path)

          [
            type, values.map do |value|
              {
                file_path: value.file_path,
                score: value.score,
                complexity: value.complexity,
                churn: value.churn,
                refactor: to_be_refactored.include?(value.file_path)
              }
            end
          ]
        end

        puts Hash[result].to_json
      end
    end

    def initialize(format:, **other)
      super(**other)
      @formatter = case format.to_sym
                   when :csv
                     CSVFormatter.new
                   when :json
                     JSONFormatter.new
                   else
                     TableFormatter.new
                   end
    end

    def report
      super
      @formatter.call(@calculators)
    end
  end
end
