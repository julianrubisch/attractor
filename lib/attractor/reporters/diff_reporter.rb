# frozen_string_literal: true

require "attractor/formatters"

module Attractor
  # Reporter for complexity deltas between two git refs
  class DiffReporter
    def initialize(format:)
      @formatter = case format.to_sym
      when :json
        Attractor::Formatters::DiffJSONFormatter.new
      when :markdown
        Attractor::Formatters::DiffMarkdownFormatter.new
      else
        Attractor::Formatters::DiffTableFormatter.new
      end
    end

    def report(data)
      puts @formatter.call(data)
    end
  end
end
