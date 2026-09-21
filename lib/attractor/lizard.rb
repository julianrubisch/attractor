# frozen_string_literal: true

require "csv"
require "open3"

module Attractor
  # Runs lizard (https://github.com/terryyin/lizard), a multi-language cyclomatic complexity
  # analyzer, and parses its CSV. Language plugins that have no native metric tool subclass
  # LizardCalculator and pass their lizard language name; this module is the only place that
  # knows how lizard is invoked.
  module Lizard
    Function = Struct.new(:name, :long_name, :ccn, :nloc, :start_line, :end_line)

    INSTALL_HINT = "lizard is not installed. Install uv (https://docs.astral.sh/uv/) so `uvx lizard` works, " \
      "or `pip install lizard`."

    module_function

    # Resolution order: a lizard on PATH (pip/pipx/brew), then uvx (fetches lizard on first run),
    # then a clear error. Memoized per process; set ATTRACTOR_LIZARD to force a command.
    def command
      @command ||= begin
        forced = ENV["ATTRACTOR_LIZARD"]
        if forced && !forced.empty?
          forced.split(" ")
        elsif executable?("lizard")
          ["lizard"]
        elsif executable?("uvx")
          ["uvx", "lizard"]
        else
          raise Attractor::Error, INSTALL_HINT
        end
      end
    end

    def reset!
      @command = nil
    end

    def analyze(file_path, language:)
      stdout, stderr, status = Open3.capture3(*command, "-l", language, "--csv", file_path)
      raise Attractor::Error, "lizard failed on #{file_path}: #{stderr.strip}" unless status.success?

      parse(stdout)
    end

    # `--csv` prints no header. Columns: nloc, ccn, token count, parameter count, length,
    # location, file, function name, long name (with parameters), start line, end line.
    def parse(csv)
      CSV.parse(csv).filter_map do |row|
        next if row.compact.empty?

        Function.new(
          name: row[7],
          long_name: row[8],
          ccn: row[1].to_i,
          nloc: row[0].to_i,
          start_line: row[9].to_i,
          end_line: row[10].to_i
        )
      end
    end

    def executable?(name)
      ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).any? do |dir|
        candidate = File.join(dir, name)
        File.file?(candidate) && File.executable?(candidate)
      end
    end
  end
end
