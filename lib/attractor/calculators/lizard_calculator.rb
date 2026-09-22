# frozen_string_literal: true

require "attractor/lizard"

module Attractor
  # Base calculator for languages scored with lizard. A plugin subclasses it and fixes the
  # language and extension:
  #
  #   class SwiftCalculator < LizardCalculator
  #     def initialize(**options)
  #       super(language: "swift", file_extension: "swift", **options)
  #       @type = "Swift"
  #     end
  #   end
  #
  # Complexity is the sum of the per-function cyclomatic complexity (McCabe, lizard's CCN),
  # which is a different scale from flog's Ruby score; attractor reports per language, so
  # the two are never summed. Details carry the same shape as attractor-ruby >= 0.4:
  # `{ "name" => { "score" => ccn, "line" => start, "end_line" => end } }`.
  class LizardCalculator < BaseCalculator
    attr_reader :language

    def initialize(language:, file_extension:, **options)
      super(file_extension: file_extension, **options)
      @language = language
      @type = language.capitalize
    end

    def calculate
      super do |change|
        functions = Lizard.analyze(change[:file_path], language: language)
        [functions.sum(&:ccn), details_for(functions)]
      end
    end

    private

    # lizard reports bare function names without their type, so overloads and same-named
    # methods in different types collide. The guarantee: a function keeps its key across
    # refs as long as its name stays unique in the file (the common case, and short keys
    # like attractor-ruby's). On collision the key is the signature (lizard's long name),
    # which is what differs between overloads and survives line shifts; the start line is
    # appended only when even the signatures match. Adding a first overload therefore moves
    # the existing function from `name` to its signature once; `diff` shows that as a
    # removed and an added entry for that one revision.
    def details_for(functions)
      by_name = functions.group_by(&:name)
      by_long_name = functions.group_by(&:long_name)

      functions.each_with_object({}) do |fn, details|
        key = if by_name[fn.name].size == 1
          fn.name
        elsif by_long_name[fn.long_name].size == 1
          fn.long_name
        else
          "#{fn.long_name}@#{fn.start_line}"
        end
        details[key] = {"score" => fn.ccn, "line" => fn.start_line, "end_line" => fn.end_line}
      end
    end
  end
end
