# frozen_string_literal: true

require "attractor/formatters"

module Attractor
  # Reporter for complexity deltas between two git refs
  class DiffReporter
    def initialize(format:)
      @formatter = Attractor::Formatters.diff(format)
    end

    def report(data)
      puts @formatter.call(data)
    end
  end
end
