require "attractor/formatters"

RSpec.describe Attractor::Formatters do
  describe ".console" do
    it "returns the table formatter by default" do
      expect(described_class.console(:table)).to be_a(Attractor::Formatters::ConsoleTableFormatter)
    end

    it "returns the csv formatter for csv" do
      expect(described_class.console(:csv)).to be_a(Attractor::Formatters::ConsoleCSVFormatter)
    end

    it "returns the json formatter for json" do
      expect(described_class.console(:json)).to be_a(Attractor::Formatters::ConsoleJSONFormatter)
    end

    it "falls back to table for unknown formats" do
      expect(described_class.console(:unknown)).to be_a(Attractor::Formatters::ConsoleTableFormatter)
    end
  end

  describe ".diff" do
    it "returns the table formatter by default" do
      expect(described_class.diff(:table)).to be_a(Attractor::Formatters::DiffTableFormatter)
    end

    it "returns the json formatter for json" do
      expect(described_class.diff(:json)).to be_a(Attractor::Formatters::DiffJSONFormatter)
    end

    it "returns the markdown formatter for markdown" do
      expect(described_class.diff(:markdown)).to be_a(Attractor::Formatters::DiffMarkdownFormatter)
    end

    it "falls back to table for unknown formats" do
      expect(described_class.diff(:unknown)).to be_a(Attractor::Formatters::DiffTableFormatter)
    end
  end
end
