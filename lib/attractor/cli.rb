# frozen_string_literal: true

require 'thor'
require 'pry'

require 'attractor'

module Attractor
  # contains methods implementing the CLI
  class CLI < Thor
    desc 'calc', 'Calculates churn and complexity for all ruby files in current directory'
    def calc
      Attractor::Calculator.calculate
      puts 'Calculated churn and complexity'
    end
  end
end
