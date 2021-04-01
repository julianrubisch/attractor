# frozen_string_literal: true

require "listen"

module Attractor
  # functionality for watching file system changes
  class Watcher
    def initialize(file_prefix, ignores, callback)
      @file_prefix = file_prefix
      @callback = callback
      @ignores = ignores.split(",").map(&:strip)
    end

    def watch
      @callback.call
      ignore = @ignores + [/^attractor_output/]

      listener = Listen.to(File.absolute_path(@file_prefix), ignore: ignore) do |modified, _added, _removed|
        if modified
          puts "#{modified.map(&:to_s).join(", ")} modified, recalculating..."
          @callback.call
        end
      end
      listener.start
      sleep
    end
  end
end
