# frozen_string_literal: true

require 'thor'

require 'attractor'

module Attractor
  # contains methods implementing the CLI
  class CLI < Thor
    desc 'calc', 'Calculates churn and complexity for all ruby files in current directory'
    option :file_prefix, aliases: :p
    option :watch, aliases: :w, type: :boolean
    def calc
      if options[:watch]
        puts 'Listening for file changes...'
        Attractor::ConsoleReporter.new(file_prefix: options[:file_prefix]).watch
      else
        Attractor::ConsoleReporter.new(file_prefix: options[:file_prefix]).report
      end
    end

    desc 'report', 'Generates an HTML report'
    option :format, aliases: :f, default: 'html'
    option :file_prefix, aliases: :p
    option :watch, aliases: :w, type: :boolean
    def report
      if options[:watch]
        puts 'Listening for file changes...'
        Attractor::HtmlReporter.new(file_prefix: options[:file_prefix]).watch
      else
        case options[:format]
        when 'html'
          Attractor::HtmlReporter.new(file_prefix: options[:file_prefix]).report
        else
          Attractor::HtmlReporter.new(file_prefix: options[:file_prefix]).report
        end
      end
    end

    desc 'serve', 'Serves the report on localhost'
    option :format, aliases: :f, default: 'html'
    option :file_prefix, aliases: :p
    option :watch, aliases: :w, type: :boolean
    def serve
      # if options[:watch]
      #   puts 'Listening for file changes...'
      #   Attractor::HtmlReporter.new(file_prefix: options[:file_prefix]).watch
      # else
        case options[:format]
        when 'html'
          Attractor::HtmlReporter.new(file_prefix: options[:file_prefix]).serve
        else
          Attractor::HtmlReporter.new(file_prefix: options[:file_prefix]).serve
        end
      # end
    end
  end
end
