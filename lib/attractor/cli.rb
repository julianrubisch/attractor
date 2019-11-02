# frozen_string_literal: true

require 'thor'

require 'attractor'

module Attractor
  # contains methods implementing the CLI
  class CLI < Thor
    desc 'calc', 'Calculates churn and complexity for all ruby files in current directory'
    option :file_prefix, aliases: :p
    option :watch, aliases: :w, type: :boolean
    option :type, aliases: :t
    def calc
      file_prefix = options[:file_prefix]
      calculators = Attractor.calculators_for_type(options[:type], file_prefix)
      if options[:watch]
        puts 'Listening for file changes...'
        Attractor::ConsoleReporter.new(file_prefix: file_prefix, calculators: calculators).watch
      else
        Attractor::ConsoleReporter.new(file_prefix: file_prefix, calculators: calculators).report
      end
    rescue RuntimeError => e
      puts "Runtime error: #{e.message}"
    end

    desc 'report', 'Generates an HTML report'
    option :format, aliases: :f, default: 'html'
    option :file_prefix, aliases: :p
    option :watch, aliases: :w, type: :boolean
    option :type, aliases: :t
    def report
      file_prefix = options[:file_prefix]
      calculators = Attractor.calculators_for_type(options[:type], file_prefix)
      if options[:watch]
        puts 'Listening for file changes...'
        Attractor::HtmlReporter.new(file_prefix: file_prefix, calculators: calculators).watch
      else
        case options[:format]
        when 'html'
          Attractor::HtmlReporter.new(file_prefix: file_prefix, calculators: calculators).report
        else
          Attractor::HtmlReporter.new(file_prefix: file_prefix, calculators: calculators).report
        end
      end
    rescue RuntimeError => e
      puts "Runtime error: #{e.message}"
    end

    desc 'serve', 'Serves the report on localhost'
    option :format, aliases: :f, default: 'html'
    option :file_prefix, aliases: :p
    option :watch, aliases: :w, type: :boolean
    option :type, aliases: :t
    def serve
      file_prefix = options[:file_prefix]
      calculators = Attractor.calculators_for_type(options[:type], file_prefix)
      if options[:watch]
        puts 'Listening for file changes...'
        Attractor::SinatraReporter.new(file_prefix: file_prefix, calculators: calculators).watch
      else
        case options[:format]
        when 'html'
          Attractor::SinatraReporter.new(file_prefix: file_prefix, calculators: calculators).report
        else
          Attractor::SinatraReporter.new(file_prefix: file_prefix, calculators: calculators).report
        end
      end
    end
  end
end
