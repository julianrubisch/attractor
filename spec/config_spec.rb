require "spec_helper"
require "tmpdir"

RSpec.describe Attractor::Config do
  describe ".load" do
    it "returns an empty hash when the file does not exist" do
      expect(described_class.load("spec/fixtures/missing.yml")).to eq({})
    end

    it "translates report keys into CLI options" do
      options = described_class.load("spec/fixtures/.attractor.yml")

      expect(options).to eq(
        file_prefix: "app",
        minimum_churn: 5,
        ignore: "vendor,node_modules",
        start_ago: "2y"
      )
    end
  end

  describe "#to_options" do
    it "ignores CI-only keys like skip and branches" do
      config = described_class.new("spec/fixtures/.attractor.yml")

      expect(config.to_options.keys).to contain_exactly(
        :file_prefix, :minimum_churn, :ignore, :start_ago
      )
    end

    it "returns an empty hash for an empty file" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, ".attractor.yml")
        File.write(path, "")

        expect(described_class.new(path).to_options).to eq({})
      end
    end

    it "returns an empty hash for a missing file" do
      expect(described_class.new("spec/fixtures/missing.yml").to_options).to eq({})
    end

    it "raises a helpful error for invalid YAML" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, ".attractor.yml")
        File.write(path, "report: [:")

        expect { described_class.new(path).to_options }.to raise_error(Attractor::Error, /Error parsing/)
      end
    end
  end
end
