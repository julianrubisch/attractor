# frozen_string_literal: true

require 'attractor/version'
require 'attractor/calculators/base_calculator'
require 'attractor/calculators/ruby_calculator'
require 'attractor/calculators/js_calculator'
require 'attractor/reporters/base_reporter'
require 'attractor/reporters/console_reporter'
require 'attractor/reporters/html_reporter'
require 'attractor/reporters/sinatra_reporter'
require 'attractor/suggester'
require 'attractor/watcher'

module Attractor
  class Error < StandardError; end

  def calculators_for_type(type, file_prefix)
    case type
    when 'js'
      { 'js' => JsCalculator.new(file_prefix: file_prefix) }
    when 'rb'
      { 'rb' => RubyCalculator.new(file_prefix: file_prefix) }
    else
      { 'rb' => RubyCalculator.new(file_prefix: file_prefix), 'js' => JsCalculator.new(file_prefix: file_prefix)}
    end
  end

  module_function :calculators_for_type
end
