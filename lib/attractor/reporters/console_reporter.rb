# frozen_string_literal: true

module Attractor
  # console reporter
  class ConsoleReporter < BaseReporter
    def report
      super
      puts 'Calculated churn and complexity'
      puts
      puts "file_path#{' ' * 53}complexity   churn"
      puts '-' * 80

      puts @values.map(&:to_s)

      puts
      puts 'Suggestions for refactorings:'
      @suggestions.each { |sug| puts sug.file_path }
      puts
    end
  end
end
