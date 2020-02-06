module Attractor
  class RegistryEntry
    attr_reader :type, :detector_class, :calculator_class

    def initialize(type:, detector_class:, calculator_class:)
      @type = type
      @detector_class = detector_class
      @calculator_class = calculator_class
    end
  end
end

