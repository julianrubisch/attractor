# frozen_string_literal: true

require "thor"

require "attractor"

module Attractor
  # contains methods implementing the CLI
  class CLI < Thor
    SHARED_DEFAULTS = {
      ignore: "",
      minimum_churn: 3,
      start_ago: "5y"
    }.freeze

    shared_options = [[:file_prefix, aliases: :p],
      [:verbose, aliases: :v, type: :boolean],
      [:ignore, aliases: :i],
      [:files, type: :string],
      [:watch, aliases: :w, type: :boolean],
      [:minimum_churn, aliases: :c, type: :numeric],
      [:start_ago, aliases: :s, type: :string],
      [:type, aliases: :t],
      [:config, type: :string, default: ".attractor.yml", desc: "Path to .attractor.yml config file"]]

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
      Attractor.init(calculators(effective_options))
    end

    desc "calc", "Calculates churn and complexity for all ruby files in current directory"
    shared_options.each do |shared_option|
      option(*shared_option)
    end
    option(:format, aliases: :f, default: :table)
    def calc
      require "attractor/reporters/console_reporter"

      opts = effective_options
      file_prefix = opts[:file_prefix]
      output_format = opts[:format]

      report! Attractor::ConsoleReporter.new(file_prefix: file_prefix, ignores: opts[:ignore], calculators: calculators(opts), format: output_format), opts
    rescue RuntimeError => e
      puts "Runtime error: #{e.message}"
    end

    desc "report", "Generates an HTML report"
    (shared_options + advanced_options).each do |option|
      option(*option)
    end
    def report
      require "attractor/reporters/html_reporter"

      opts = effective_options
      file_prefix = opts[:file_prefix]
      open_browser = !(opts[:no_open_browser] || opts[:ci])

      report! Attractor::HtmlReporter.new(file_prefix: file_prefix, ignores: opts[:ignore], calculators: calculators(opts), open_browser: open_browser), opts
    rescue RuntimeError => e
      puts "Runtime error: #{e.message}"
    end

    desc "serve", "Serves the report on localhost"
    (shared_options + advanced_options).each do |option|
      option(*option)
    end
    def serve
      require "attractor/reporters/sinatra_reporter"

      opts = effective_options
      file_prefix = opts[:file_prefix]
      open_browser = !(opts[:no_open_browser] || opts[:ci])

      report! Attractor::SinatraReporter.new(file_prefix: file_prefix, ignores: opts[:ignore], calculators: calculators(opts), open_browser: open_browser), opts
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

      opts = effective_options
      file_list = parse_files(opts[:files])
      file_list ||= default_diff_files(opts[:base], opts[:head])

      data = Attractor::DiffCalculator.new(
        base_ref: opts[:base],
        head_ref: opts[:head],
        files: file_list,
        file_prefix: opts[:file_prefix],
        minimum_churn_count: opts[:minimum_churn],
        ignores: opts[:ignore],
        start_ago: opts[:start_ago],
        verbose: opts[:verbose],
        type: opts[:type]
      ).calculate

      Attractor::DiffReporter.new(format: opts[:format]).report(data)
    rescue ArgumentError, RuntimeError => e
      puts "Runtime error: #{e.message}"
    end

    private

    def effective_options
      @effective_options ||= begin
        config_options = Attractor::Config.load(options[:config])
        cli_options = options.to_hash.transform_keys(&:to_sym).reject { |_, v| v.nil? }
        merged = config_options.merge(cli_options)
        SHARED_DEFAULTS.merge(merged) { |_key, default, val| val.nil? ? default : val }
      end
    end

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

    def report!(reporter, options)
      if options[:watch]
        puts "Listening for file changes..."
        reporter.watch
      else
        reporter.report
      end
    end
  end
end
