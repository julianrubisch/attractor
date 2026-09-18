# frozen_string_literal: true

require "thor"

require "attractor"

module Attractor
  # contains methods implementing the CLI
  class CLI < Thor
    shared_options = [[:file_prefix, aliases: :p],
      [:verbose, aliases: :v, type: :boolean],
      [:ignore, aliases: :i, default: ""],
      [:files, type: :string],
      [:watch, aliases: :w, type: :boolean],
      [:minimum_churn, aliases: :c, type: :numeric, default: 3],
      [:start_ago, aliases: :s, type: :string, default: "5y"],
      [:type, aliases: :t]]

    advanced_options = [[:format, aliases: :f, default: "html"],
      [:no_open_browser, type: :boolean],
      [:ci, type: :boolean]]

    desc "version", "Prints Attractor's version information"
    map %w[-v --version] => :version
    def version
      puts "Attractor version #{Attractor::VERSION}"
    rescue RuntimeError => e
      puts "Runtime error: #{e.message}"
    end

    desc "clean", "Clears attractor's cache"
    def clean
      puts "Clearing attractor cache"
      Attractor.clear
    end

    desc "init", "Initializes attractor's cache"
    shared_options.each do |shared_option|
      option(*shared_option)
    end
    def init
      puts "Warming attractor cache"
      Attractor.init(calculators(options))
    end

    desc "calc", "Calculates churn and complexity for all ruby files in current directory"
    shared_options.each do |shared_option|
      option(*shared_option)
    end
    option(:format, aliases: :f, default: :table)
    def calc
      require "attractor/reporters/console_reporter"

      file_prefix = options[:file_prefix]
      output_format = options[:format]

      report! Attractor::ConsoleReporter.new(file_prefix: file_prefix, ignores: options[:ignore], calculators: calculators(options), format: output_format)
    rescue RuntimeError => e
      puts "Runtime error: #{e.message}"
    end

    desc "report", "Generates an HTML report"
    (shared_options + advanced_options).each do |option|
      option(*option)
    end
    def report
      require "attractor/reporters/html_reporter"

      file_prefix = options[:file_prefix]
      open_browser = !(options[:no_open_browser] || options[:ci])

      report! Attractor::HtmlReporter.new(file_prefix: file_prefix, ignores: options[:ignore], calculators: calculators(options), open_browser: open_browser)
    rescue RuntimeError => e
      puts "Runtime error: #{e.message}"
    end

    desc "serve", "Serves the report on localhost"
    (shared_options + advanced_options).each do |option|
      option(*option)
    end
    def serve
      require "attractor/reporters/sinatra_reporter"

      file_prefix = options[:file_prefix]
      open_browser = !(options[:no_open_browser] || options[:ci])

      report! Attractor::SinatraReporter.new(file_prefix: file_prefix, ignores: options[:ignore], calculators: calculators(options), open_browser: open_browser)
    end

    desc "diff", "Calculates complexity delta between two git refs"
    option :base, required: true
    option :head, required: true
    shared_options.each do |shared_option|
      option(*shared_option)
    end
    option :format, aliases: :f, default: :table
    def diff
      require "attractor/diff_calculator"
      require "attractor/reporters/diff_reporter"

      file_list = parse_files(options[:files])
      file_list ||= default_diff_files(options[:base], options[:head])

      data = Attractor::DiffCalculator.new(
        base_ref: options[:base],
        head_ref: options[:head],
        files: file_list,
        file_prefix: options[:file_prefix],
        minimum_churn_count: options[:minimum_churn],
        ignores: options[:ignore],
        start_ago: options[:start_ago],
        verbose: options[:verbose],
        type: options[:type]
      ).calculate

      Attractor::DiffReporter.new(format: options[:format]).report(data)
    rescue ArgumentError, RuntimeError => e
      puts "Runtime error: #{e.message}"
    end

    private

    def calculators(options)
      Attractor.calculators_for_type(options[:type],
        file_prefix: options[:file_prefix],
        minimum_churn_count: options[:minimum_churn],
        ignores: options[:ignore],
        start_ago: options[:start_ago],
        verbose: options[:verbose],
        files: parse_files(options[:files]))
    end

    def parse_files(value)
      return nil if value.nil? || value.to_s.empty?

      if value == "-"
        $stdin.read.lines(chomp: true).reject(&:empty?)
      else
        value.split(",").map(&:strip).reject(&:empty?)
      end
    end

    def default_diff_files(base_ref, head_ref)
      `git diff --name-only #{base_ref}...#{head_ref}`.lines(chomp: true).reject(&:empty?)
    end

    def report!(reporter)
      if options[:watch]
        puts "Listening for file changes..."
        reporter.watch
      else
        reporter.report
      end
    end
  end
end
