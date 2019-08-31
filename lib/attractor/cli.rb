# frozen_string_literal: true

require 'thor'

require 'attractor'

module Attractor
  # contains methods implementing the CLI
  class CLI < Thor
    desc 'calc', 'Calculates churn and complexity for all ruby files in current directory'
    def calc
      puts 'Calculated churn and complexity'
      puts
      puts "file_path#{' ' * 53}complexity   churn"
      puts '-' * 80
      Attractor::Calculator.output_console
    end

    desc 'report', 'Generates an HTML report'
    option :format, aliases: :f, default: 'html'
    option :file_prefix, aliases: :p
    def report
      puts 'Generating an HTML report'
      Attractor::Calculator.report(format: options[:format], file_prefix: options[:file_prefix])
      puts "Generated HTML report at #{File.expand_path './attractor_output/index.html'}"
    end
  end
end
