# frozen_string_literal: true

require "attractor/formatters/formatter"
require "attractor/formatters/targets/diff"
require "attractor/formatters/formats/json"
require "attractor/formatters/formats/table"
require "attractor/formatters/formats/markdown"

module Attractor
  # Reporter for complexity deltas between two git refs
  class DiffReporter
    def initialize(format:)
      @formatter = Attractor::Formatters::Formatter.new(
        target: Attractor::Formatters::Targets::Diff.new,
        format: format_strategy(format)
      )
    end

    def report(data)
      puts @formatter.call(data)
    end

    private

    def format_strategy(format)
      case format.to_sym
      when :json then Attractor::Formatters::Formats::JSON.new
      when :markdown then Attractor::Formatters::Formats::Markdown.new
      else Attractor::Formatters::Formats::Table.new
      end
    end
  end
end
