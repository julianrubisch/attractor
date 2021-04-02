# frozen_string_literal: true

require "fileutils"
require "psych"

module Attractor
  class Cache
    class << self
      def read(file_path:)
      end

      def write(file_path:, value:)
        adapter.write(file_path: file_path, value: value)
      end

      private

      def adapter
        @@adapter ||= CacheAdapter::JSON.instance
      end
    end
  end

  module CacheAdapter
    class Base
      include Singleton
    end

    class JSON < Base
      def initialize
        super

        @data_directory = "tmp"
        FileUtils.mkdir_p @data_directory
        FileUtils.touch filename

        begin
          @store = ::JSON.parse(filename)
        rescue ::JSON::ParserError
          @store = {}
        end
      end

      def write(file_path:, value:)
        @store[file_path] = {value.current_commit => value.to_h}
        File.write(filename, ::JSON.dump(@store))
      end

      def filename
        "#{@data_directory}/attractor-cache.json"
      end
    end
  end
end
