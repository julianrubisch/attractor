# frozen_string_literal: true

require 'thor'

require 'attractor'

module Attractor
  # contains methods implementing the CLI
  class CLI < Thor
    desc 'calc', 'Calculates churn and complexity for all ruby files in current directory'
    def calc
      puts 'Calculated churn and complexity'
      puts
      puts "file_path#{' ' * 53}complexity   churn"
      puts '-' * 80
      Attractor::Calculator.calculate
    end
  end
end
