# frozen_string_literal: true

module Attractor
  module Formatters
    module FormatStrategy
      private

      def format_strategy(format)
        case format.to_sym
        when :csv then Formats::CSV.new
        when :json then Formats::JSON.new
        when :markdown then Formats::Markdown.new
        when :table then Formats::Table.new
        else
          raise ArgumentError, "Unknown format: #{format}"
        end
      end
    end
  end
end
