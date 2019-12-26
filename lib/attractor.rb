# frozen_string_literal: true

require 'attractor/version'
require 'attractor/calculators/base_calculator'
require 'attractor/calculators/ruby_calculator'
require 'attractor/calculators/js_calculator'
require 'attractor/detectors/base_detector'
require 'attractor/detectors/ruby_detector'
require 'attractor/detectors/js_detector'
require 'attractor/reporters/base_reporter'
require 'attractor/reporters/console_reporter'
require 'attractor/reporters/html_reporter'
require 'attractor/reporters/sinatra_reporter'
require 'attractor/suggester'
require 'attractor/watcher'

module Attractor
  class Error < StandardError; end

  def calculators_for_type(type, file_prefix, minimum_churn_count)
    options = { file_prefix: file_prefix, minimum_churn_count: minimum_churn_count }
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
