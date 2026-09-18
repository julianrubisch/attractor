# frozen_string_literal: true

require "yaml"

module Attractor
  # Reads `.attractor.yml` configuration from disk and exposes it
  # as a hash of CLI-compatible options.
  class Config
    DEFAULT_PATH = ".attractor.yml"

    def self.load(path = DEFAULT_PATH)
      new(path).to_options
    end

    def initialize(path = DEFAULT_PATH)
      @path = path
      @data = load_yaml
    end

    # Translates the YAML structure into options understood by the CLI.
    # Unknown keys (e.g. branches, skip) are ignored because they are
    # currently only relevant in CI/SaaS contexts.
    def to_options
      return {} unless @data

      report = @data["report"] || {}

      {
        file_prefix: report["app_root"],
        minimum_churn: report["minimum_churn"],
        ignore: report["ignore"],
        start_ago: report["start_ago"]
      }.compact
    end

    private

    def load_yaml
      return {} unless File.exist?(@path)

      contents = File.read(@path)
      parsed = if Psych::VERSION >= "5.0"
        YAML.safe_load(contents, permitted_classes: [], permitted_symbols: [], aliases: true)
      else
        YAML.safe_load(contents, [], [], true)
      end

      parsed || {}
    rescue Psych::SyntaxError => e
      raise Error, "Error parsing #{@path}: #{e.message}"
    end
  end
end
