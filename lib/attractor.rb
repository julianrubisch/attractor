# frozen_string_literal: true

require 'attractor/version'
require 'attractor/duration_parser'
require 'attractor/calculators/base_calculator'
require 'attractor/detectors/base_detector'
require 'attractor/reporters/base_reporter'
require 'attractor/suggester'
require 'attractor/watcher'

Dir[File.join(__dir__, 'attractor', 'calculators', '*.rb')].each do |file|
  next if file.start_with?('base')

  require file
end

Dir[File.join(__dir__, 'attractor', 'detectors', '*.rb')].each do |file|
  next if file.start_with?('base')

  require file
end

Dir[File.join(__dir__, 'attractor', 'reporters', '*.rb')].each do |file|
  next if file.start_with?('base')

  require file
end

module Attractor
  class Error < StandardError; end

  def calculators_for_type(type, **options)
    case type
    when 'js'
      { 'js' => JsCalculator.new(**options) }
    when 'rb'
      { 'rb' => RubyCalculator.new(**options) }
    else
      {}.tap do |hash|
        hash['rb'] = RubyCalculator.new(**options) if RubyDetector.new.detect
        hash['js'] = JsCalculator.new(**options) if JsDetector.new.detect
      end
    end
  end

  module_function :calculators_for_type
end
