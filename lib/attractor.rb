# frozen_string_literal: true

require 'attractor/version'
require 'attractor/calculator'
require 'attractor/reporters/base_reporter'
require 'attractor/reporters/console_reporter'
# require 'attractor/reporters/base_reporter'
require 'attractor/reporters/sinatra_reporter'
require 'attractor/suggester'
require 'attractor/watcher'

module Attractor
  class Error < StandardError; end
  # Your code goes here...
end
