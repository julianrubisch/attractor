# frozen_string_literal: true

require "descriptive_statistics/safe"
require "fileutils"
require "forwardable"
require "launchy"
require "tilt"

module Attractor
  # base reporter
  class BaseReporter
    extend Forwardable
    attr_accessor :file_prefix
    attr_reader :types
    attr_writer :values
    def_delegator :@watcher, :watch

    def initialize(file_prefix:, calculators:, open_browser: true)
      @file_prefix = file_prefix || ""
      @calculators = calculators
      @open_browser = open_browser
      @values = @calculators.first.last.calculate
      @suggester = Suggester.new(values)

      @watcher = Watcher.new(@file_prefix, lambda do
        report
      end)
    rescue NoMethodError => _e
      raise "There was a problem gathering churn changes"
    end

    def suggestions(quantile:, type: "rb")
      @suggester.values = values(type: type)
      @suggestions = @suggester.suggest(quantile)
      @suggestions
    end

    def report
      @suggestions = @suggester.suggest
      @types = Hash[@calculators.map { |calc| [calc.first, calc.last.type] }]
    end

    def render
      "Attractor"
    end

    def values(type: "rb")
      @values = @calculators[type].calculate
      @values
    rescue NoMethodError => _e
      puts "No calculator for type #{type}"
    end
  end
end
