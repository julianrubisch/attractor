# frozen_string_literal: true

require 'descriptive_statistics/safe'
require 'fileutils'
require 'forwardable'
require 'launchy'
require 'tilt'

module Attractor
  # base reporter
  class BaseReporter
    extend Forwardable
    attr_accessor :values, :file_prefix
    attr_reader :types
    def_delegator :@watcher, :watch

    def initialize(file_prefix: '', calculators:, open_browser: true)
      @file_prefix = file_prefix
      @calculators = calculators
      @open_browser = open_browser
      @values = @calculators.first.last.calculate
      @suggester = Suggester.new(values)

      @watcher = Watcher.new(file_prefix, lambda do
        report
      end)
    rescue NoMethodError => e
      raise 'There was a problem gathering churn changes'
    end

    def suggestions(quantile)
      @suggestions = @suggester.suggest(quantile)
      @suggestions
    end

    def report
      @suggestions = @suggester.suggest
      @types = Hash[@calculators.map { |calc| [calc.first, calc.last.type] }]
    end

    def render
      'Attractor'
    end
  end
end
