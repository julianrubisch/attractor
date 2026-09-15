# frozen_string_literal: true

RSpec.describe Attractor do
  it "has a version number" do
    expect(Attractor::VERSION).not_to be nil
  end

  it "suggests the 95 percentile refactoring candidates" do
    values = 1.upto(30).map do |index|
      Attractor::Value.new(file_path: "file_#{index}.rb", churn: index, complexity: index)
    end

    suggester = Attractor::Suggester.new(values)
    suggestions = suggester.suggest

    expect(suggestions.map(&:file_path)).to contain_exactly "file_30.rb", "file_29.rb"
    expect(suggestions.map(&:file_path)).not_to include "file_28.rb"
  end

  describe Attractor::Value do
    it "returns nil for score when complexity is nil" do
      value = Attractor::Value.new(file_path: "deleted.rb", churn: 3, complexity: nil)

      expect(value.score).to be_nil
    end

    it "prints n/a for nil complexity" do
      value = Attractor::Value.new(file_path: "deleted.rb", churn: 3, complexity: nil)

      expect(value.to_s).to include("n/a")
    end
  end

  describe Attractor::Suggester do
    it "ignores values with nil scores" do
      values = 1.upto(30).map do |index|
        Attractor::Value.new(file_path: "file_#{index}.rb", churn: index, complexity: index)
      end
      values << Attractor::Value.new(file_path: "deleted.rb", churn: 100, complexity: nil)

      suggestions = Attractor::Suggester.new(values).suggest

      expect(suggestions.map(&:file_path)).to contain_exactly("file_30.rb", "file_29.rb")
      expect(suggestions.map(&:file_path)).not_to include("deleted.rb")
    end
  end
end
