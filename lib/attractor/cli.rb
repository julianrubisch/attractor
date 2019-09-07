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
      Attractor::ConsoleReporter.new(file_prefix: options[:file_prefix]).report
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
        puts "Generated HTML report at #{File.expand_path './attractor_output/index.html'}"
        case options[:format]
        when 'html'
          Attractor::HtmlReporter.new(file_prefix: options[:file_prefix]).report
        else
          Attractor::HtmlReporter.new(file_prefix: options[:file_prefix]).report
        end
      end
    end
  end
end
