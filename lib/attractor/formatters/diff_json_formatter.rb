# frozen_string_literal: true

require "json"
require "attractor/formatters/base_formatter"

module Attractor
  module Formatters
    class DiffJSONFormatter < BaseFormatter
      def call(data)
        data.to_json
      end
    end
  end
end
