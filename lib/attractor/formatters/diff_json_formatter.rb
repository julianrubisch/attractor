# frozen_string_literal: true

require "json"

module Attractor
  module Formatters
    class DiffJSONFormatter
      def call(data)
        data.to_json
      end
    end
  end
end
