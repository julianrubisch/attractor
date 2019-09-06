# frozen_string_literal: true

require 'thor'

require 'attractor'

module Attractor
  # contains methods implementing the CLI
  class CLI < Thor
    desc 'calc', 'Calculates churn and complexity for all ruby files in current directory'
    option :file_prefix, aliases: :p
    option :watch, aliases: :w, type: :boolean
    def calc
      puts 'Calculated churn and complexity'
      puts
      puts "file_path#{' ' * 53}complexity   churn"
      puts '-' * 80
      Attractor::Calculator.output_console(file_prefix: options[:file_prefix])
    end

    desc 'report', 'Generates an HTML report'
    option :format, aliases: :f, default: 'html'
    option :file_prefix, aliases: :p
    option :watch, aliases: :w, type: :boolean
    def report
      puts 'Generating an HTML report'
      if options[:watch]
        puts 'Listening for file changes...'
        Attractor::Calculator.watch(file_prefix: options[:file_prefix])
      else
        Attractor::Calculator.report(format: options[:format], file_prefix: options[:file_prefix])
        puts "Generated HTML report at #{File.expand_path './attractor_output/index.html'}"
      end
    end
  end
end
