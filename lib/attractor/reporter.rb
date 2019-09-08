# frozen_string_literal: true

require 'descriptive_statistics/safe'
require 'fileutils'
require 'tilt'

module Attractor
  # base reporter
  class Reporter
    extend Forwardable
    attr_accessor :values
    def_delegator :@watcher, :watch

    def initialize(file_prefix: '')
      @calculator = Calculator.new(file_prefix: file_prefix)
      @values = @calculator.calculate
      @suggester = Suggester.new(values)

      @watcher = Watcher.new(file_prefix, lambda do
        report
      end)
    end

    def report
      @suggestions = @suggester.suggest
    end
  end

  # console reporter
  class ConsoleReporter < Reporter
    def report
      super
      puts @values.map(&:to_s)

      puts
      puts 'Suggestions for refactorings:'
      @suggestions.each { |sug| puts sug.file_path }
    end
  end

  # HTML reporter
  class HtmlReporter < Reporter
    def report
      super

      puts 'Generating an HTML report'
      template = Tilt.new(File.expand_path('../templates/index.html.erb', __dir__))
      output = template.render self

      FileUtils.mkdir_p './attractor_output'

      File.open('./attractor_output/index.html', 'w') { |file| file.write(output) }
      puts "Generated HTML report at #{File.expand_path './attractor_output/index.html'}"
    end
  end
end
