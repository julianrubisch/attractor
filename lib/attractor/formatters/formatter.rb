# frozen_string_literal: true

module Attractor
  module Formatters
    class Formatter
      def initialize(target:, format:)
        @target = target_for(target)
        @format = format_for(format)
      end

      def call(data)
        @format.call(@target.call(data))
      end

      private

      def target_for(target)
        case target.to_sym
        when :console then Targets::Console.new
        when :diff then Targets::Diff.new
        else
          raise ArgumentError, "Unknown target: #{target}"
        end
      end

      def format_for(format)
        case format.to_sym
        when :json then Formats::JSON.new
        when :table then Formats::Table.new
        when :csv then Formats::CSV.new
        when :markdown then Formats::Markdown.new
        else
          raise ArgumentError, "Unknown format: #{format}"
        end
      end
    end
  end
end
