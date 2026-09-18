# frozen_string_literal: true

module Attractor
  module Formatters
    class Report
      attr_reader :title, :metadata, :columns, :rows, :footer, :group_by, :rows_key

      def initialize(title:, columns:, rows:, metadata: {}, footer: nil, group_by: nil, rows_key: :rows)
        @title = title
        @metadata = metadata
        @columns = columns
        @rows = rows
        @footer = footer
        @group_by = group_by
        @rows_key = rows_key
      end
    end
  end
end
