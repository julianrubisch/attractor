# frozen_string_literal: true

module Attractor
  module Formatters
    class Formatter
      def initialize(target:, format:)
        @target = target
        @format = format
      end

      def call(data)
        @format.call(@target.call(data))
      end
    end
  end
end
