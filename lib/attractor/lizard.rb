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

    # nloc, ccn, tokens, params, length, location, file, name, long name, start, end
    CSV_COLUMNS = 11

    module_function

    # Resolution order: a lizard on PATH (pip/pipx/brew), then uvx (fetches lizard on first run),
    # then a clear error. Memoized per process; set ATTRACTOR_LIZARD to force a command.
    # Windows note: this looks for the bare names, not PATHEXT variants; attractor is not
    # tested there, and ATTRACTOR_LIZARD covers it.
    def command
      @command ||= begin
        forced = ENV["ATTRACTOR_LIZARD"].to_s.split
        if forced.any?
          forced
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

      parse(stdout, file_path: file_path)
    end

    # `--csv` prints no header. Anything that is not a full row (a warning lizard writes to
    # stdout, a blank line) is dropped rather than turned into a phantom function; a source
    # file with bytes lizard echoes verbatim must not take the whole run down either.
    def parse(csv, file_path: nil)
      clean = csv.dup.force_encoding(Encoding::UTF_8).scrub("?")

      CSV.parse(clean).filter_map do |row|
        next unless row.size >= CSV_COLUMNS && integer?(row[1]) && integer?(row[9]) && integer?(row[10])

        Function.new(row[7].to_s, row[8].to_s, row[1].to_i, row[0].to_i, row[9].to_i, row[10].to_i)
      end
    rescue CSV::MalformedCSVError => e
      where = file_path ? " for #{file_path}" : nil
      raise Attractor::Error, "lizard produced unreadable CSV#{where}: #{e.message}"
    end

    def integer?(value)
      value.to_s.match?(/\A-?\d+\z/)
    end

    def executable?(name)
      ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).any? do |dir|
        candidate = File.join(dir, name)
        File.file?(candidate) && File.executable?(candidate)
      end
    end
  end
end
