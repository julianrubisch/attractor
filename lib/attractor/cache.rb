# frozen_string_literal: true

require "fileutils"
require "psych"

module Attractor
  class Cache
    class << self
      def read(file_path:)
        adapter.read(file_path: file_path)
      end

      def write(file_path:, value:)
        adapter.write(file_path: file_path, value: value)
      end

      def persist!
        adapter.persist!
      end

      def clear
        adapter.clear
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
          @store = ::JSON.parse(File.read(filename))
        rescue ::JSON::ParserError
          @store = {}
        end
      end

      def read(file_path:)
        value_hash = @store[file_path]

        Value.new(**value_hash.values.first.transform_keys(&:to_sym)) unless value_hash.nil?
      rescue ArgumentError => e
        puts "Couldn't rehydrate value from cache: #{e.message}"
        nil
      end

      def write(file_path:, value:)
        mappings = {x: :churn, y: :complexity}

        transformed_value = value.to_h.transform_keys { |k| mappings[k] || k }
        @store[file_path] = {value.current_commit => transformed_value}
      end

      def persist!
        File.write(filename, ::JSON.dump(@store))
      end

      def clear
        FileUtils.rm filename
      end

      def filename
        "#{@data_directory}/attractor-cache.json"
      end
    end
  end
end
