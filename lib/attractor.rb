# frozen_string_literal: true

require "attractor/version"
require "attractor/gem_names"
require "attractor/duration_parser"
require "attractor/calculators/base_calculator"
require "attractor/detectors/base_detector"
require "attractor/reporters/base_reporter"
require "attractor/suggester"
require "attractor/watcher"
require "attractor/cache"

module Attractor
  class Error < StandardError; end

  @registry_entries = {}

  def init(calculators)
    calculators ||= all_registered_calculators
    calculators.to_a.map(&:last).each(&:calculate)
  end

  def clear
    Cache.clear
  end

  def register(registry_entry)
    @registry_entries[registry_entry.type] = registry_entry
  end

  def calculators_for_type(type, **options)
    files = options.delete(:files)
    registry_entry_for_type = @registry_entries[type]

    if type
      calculator = registry_entry_for_type.calculator_class.new(**options)
      calculator.files = files if calculator.respond_to?(:files=)
      return {type => calculator}
    end

    all_registered_calculators(**options).tap do |calculators|
      calculators.each_value do |calculator|
        calculator.files = files if calculator.respond_to?(:files=)
      end
    end
  end

  def all_registered_calculators(options = {})
    @registry_entries.map do |type, entry|
      [type, entry.calculator_class.new(**options)] if entry.detector_class.new.detect
    end.compact.to_h
  end

  module_function :calculators_for_type
  module_function :all_registered_calculators
  module_function :register
  module_function :init
  module_function :clear
end

Attractor::GemNames.new.to_a.each do |gem_name|
  require "attractor/#{gem_name}"
end
