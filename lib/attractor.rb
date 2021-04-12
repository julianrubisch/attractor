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

Dir[File.join(__dir__, "attractor", "reporters", "*.rb")].sort.each do |file|
  next if file.start_with?("base")

  require file
end

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
    registry_entry_for_type = @registry_entries[type]

    return {type => registry_entry_for_type.calculator_class.new(**options)} if type

    all_registered_calculators(**options)
  end

  def all_registered_calculators(options = {})
    Hash[@registry_entries.map do |type, entry|
      [type, entry.calculator_class.new(**options)] if entry.detector_class.new.detect
    end.compact]
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
