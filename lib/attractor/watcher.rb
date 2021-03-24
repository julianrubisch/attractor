# frozen_string_literal: true

require "listen"

module Attractor
  # functionality for watching file system changes
  class Watcher
    def initialize(file_prefix, callback)
      @file_prefix = file_prefix
      @callback = callback
    end

    def watch
      @callback.call

      listener = Listen.to(File.absolute_path(@file_prefix), ignore: /^attractor_output/) do |modified, _added, _removed|
        if modified
          puts "#{modified.map(&:to_s).join(', ')} modified, recalculating..."
          @callback.call
        end
      end
      listener.start
      sleep
    end
  end
end
