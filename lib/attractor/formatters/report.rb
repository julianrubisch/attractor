# frozen_string_literal: true

module Attractor
  module Formatters
    class Report
      attr_reader :title, :metadata, :columns, :rows, :footer, :group_by, :rows_key, :sections, :collapsed_table

      def initialize(title:, columns:, rows:, metadata: {}, footer: nil, group_by: nil, rows_key: :rows, sections: [], collapsed_table: false)
        @title = title
        @metadata = metadata
        @columns = columns
        @rows = rows
        @footer = footer
        @group_by = group_by
        @rows_key = rows_key
        @sections = sections
        @collapsed_table = collapsed_table
      end
    end
  end
end
