# frozen_string_literal: true

require 'churn/calculator'
require 'csv'
require 'date'
require 'descriptive_statistics/safe'
require 'flog'
require 'fileutils'
require 'listen'
require 'tilt'

require 'attractor/value'

module Attractor
  # calculates churn and complexity
  class Calculator
    def self.calculate(file_extension: 'rb', minimum_churn_count: 3, file_prefix: '')
      churn = ::Churn::ChurnCalculator.new(
        file_extension: file_extension,
        file_prefix: file_prefix,
        minimum_churn_count: minimum_churn_count,
        start_date: Date.today - 365 * 5
      ).report(false)

      churn[:churn][:changes].map do |change|
        flogger = Flog.new(all: true)
        flogger.flog(change[:file_path])
        complexity = flogger.total_score
        Value.new(file_path: change[:file_path], churn: change[:times_changed], complexity: complexity)
      end
    end

    def self.output_console(file_prefix: '')
      values = calculate(file_prefix: file_prefix)
      puts values.map(&:to_s)
    end

    def self.report(format: 'html', file_prefix: '')
      @values = calculate(file_prefix: file_prefix)

      @suggestions = get_suggestions(@values)

      template = Tilt.new(File.expand_path('../templates/index.html.erb', __dir__))
      output = template.render self

      FileUtils.mkdir_p './attractor_output'

      case format
      when 'html'
        File.open('./attractor_output/index.html', 'w') { |file| file.write(output) }
      end
    end

    def self.get_suggestions(values)
      products = values.map { |val| val.churn * val.complexity }
      products.extend(DescriptiveStatistics)
      top_95_quantile = products.percentile(95)

      values.select { |val| val.churn * val.complexity > top_95_quantile }
    end

    def self.watch(file_prefix: '')
      listener = Listen.to(file_prefix) do |_modified, _added, _removed|
        puts "modified #{modified}"
      end
      listener.start
      sleep
    end
  end
end
