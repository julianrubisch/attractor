# frozen_string_literal: true

require 'thor'

require 'attractor'

module Attractor
  # contains methods implementing the CLI
  class CLI < Thor
    shared_options = [[:file_prefix, aliases: :p],
                      [:watch, aliases: :w, type: :boolean],
                      [:minimum_churn, aliases: :c, type: :numeric, default: 3],
                      [:start_ago, aliases: :s, type: :string, default: '5y'],
                      [:type, aliases: :t]]

    advanced_options = [[:format, aliases: :f, default: 'html'],
                        [:no_open_browser, type: :boolean],
                        [:ci, type: :boolean]]

    desc "version", "Prints Attractor's version information"
    map %w(-v --version) => :version
    def version
      puts "Attractor version #{Attractor::VERSION}"
    rescue RuntimeError => e
      puts "Runtime error: #{e.message}"
    end

    desc 'calc', 'Calculates churn and complexity for all ruby files in current directory'
    shared_options.each do |shared_option|
      option(*shared_option)
    end
    def calc
      file_prefix = options[:file_prefix]
      if options[:watch]
        puts 'Listening for file changes...'
        Attractor::ConsoleReporter.new(file_prefix: file_prefix, calculators: calculators(options)).watch
      else
        Attractor::ConsoleReporter.new(file_prefix: file_prefix, calculators: calculators(options)).report
      end
    rescue RuntimeError => e
      puts "Runtime error: #{e.message}"
    end

    desc 'report', 'Generates an HTML report'
    (shared_options + advanced_options).each do |option|
      option(*option)
    end
    def report
      file_prefix = options[:file_prefix]
      open_browser = !(options[:no_open_browser] || options[:ci])
      if options[:watch]
        puts 'Listening for file changes...'
        Attractor::HtmlReporter.new(file_prefix: file_prefix, calculators: calculators(options), open_browser: open_browser).watch
      else
        case options[:format]
        when 'html'
          Attractor::HtmlReporter.new(file_prefix: file_prefix, calculators: calculators(options), open_browser: open_browser).report
        else
          Attractor::HtmlReporter.new(file_prefix: file_prefix, calculators: calculators(options), open_browser: open_browser).report
        end
      end
    rescue RuntimeError => e
      puts "Runtime error: #{e.message}"
    end

    desc 'serve', 'Serves the report on localhost'
    (shared_options + advanced_options).each do |option|
      option(*option)
    end
    def serve
      file_prefix = options[:file_prefix]
      open_browser = !(options[:no_open_browser] || options[:ci])
      if options[:watch]
        puts 'Listening for file changes...'
        Attractor::SinatraReporter.new(file_prefix: file_prefix, calculators: calculators(options), open_browser: open_browser).watch
      else
        case options[:format]
        when 'html'
          Attractor::SinatraReporter.new(file_prefix: file_prefix, calculators: calculators(options), open_browser: open_browser).report
        else
          Attractor::SinatraReporter.new(file_prefix: file_prefix, calculators: calculators(options), open_browser: open_browser).report
        end
      end
    end

    private

    def calculators(options)
      Attractor.calculators_for_type(options[:type],
                                     file_prefix: options[:file_prefix],
                                     minimum_churn_count: options[:minimum_churn],
                                     start_ago: options[:start_ago])
    end
  end
end
