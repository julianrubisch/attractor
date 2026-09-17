# frozen_string_literal: true

require "attractor/formatters/format_helpers"
require "attractor/formatters/console_table_formatter"
require "attractor/formatters/console_csv_formatter"
require "attractor/formatters/console_json_formatter"
require "attractor/formatters/diff_table_formatter"
require "attractor/formatters/diff_json_formatter"
require "attractor/formatters/diff_markdown_formatter"

module Attractor
  module Formatters
    CONSOLE_FORMATTERS = {
      csv: ConsoleCSVFormatter,
      json: ConsoleJSONFormatter,
      table: ConsoleTableFormatter
    }.freeze

    DIFF_FORMATTERS = {
      json: DiffJSONFormatter,
      markdown: DiffMarkdownFormatter,
      table: DiffTableFormatter
    }.freeze

    def self.console(format)
      CONSOLE_FORMATTERS.fetch(format.to_sym, ConsoleTableFormatter).new
    end

    def self.diff(format)
      DIFF_FORMATTERS.fetch(format.to_sym, DiffTableFormatter).new
    end
  end
end
