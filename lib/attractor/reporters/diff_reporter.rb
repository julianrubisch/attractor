# frozen_string_literal: true

require "attractor/formatters/formatter"
require "attractor/formatters/targets/diff"
require "attractor/formatters/formats/json"
require "attractor/formatters/formats/table"
require "attractor/formatters/formats/markdown"
require "attractor/formatters/format_strategy"

module Attractor
  # Reporter for complexity deltas between two git refs
  class DiffReporter
    include Attractor::Formatters::FormatStrategy

    def initialize(format:)
      @formatter = Attractor::Formatters::Formatter.new(
        target: Attractor::Formatters::Targets::Diff.new,
        format: format_strategy(format)
      )
    end

    def report(data)
      puts @formatter.call(data)
    end
  end
end
