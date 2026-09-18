require "spec_helper"
require "attractor/cli"

RSpec.describe Attractor::CLI do
  describe "#effective_options" do
    let(:cli) { described_class.new }
    let(:config_path) { "spec/fixtures/.attractor.yml" }

    before do
      allow(cli).to receive(:options).and_return(
        Thor::CoreExt::HashWithIndifferentAccess.new(
          config: config_path,
          file_prefix: nil,
          verbose: nil,
          ignore: nil,
          files: nil,
          watch: nil,
          minimum_churn: nil,
          start_ago: nil,
          type: nil
        )
      )
    end

    it "loads values from the config file" do
      expect(cli.send(:effective_options)).to include(
        file_prefix: "app",
        minimum_churn: 5,
        ignore: "vendor,node_modules",
        start_ago: "2y"
      )
    end

    it "applies built-in defaults for unspecified options" do
      options = cli.send(:effective_options)

      expect(options[:minimum_churn]).to eq(5)
      expect(options[:ignore]).to eq("vendor,node_modules")
      expect(options[:start_ago]).to eq("2y")
    end

    it "lets explicit CLI options override config values" do
      allow(cli).to receive(:options).and_return(
        Thor::CoreExt::HashWithIndifferentAccess.new(
          config: config_path,
          file_prefix: "lib",
          verbose: true,
          ignore: "spec",
          files: nil,
          watch: nil,
          minimum_churn: 10,
          start_ago: "1m",
          type: "rb"
        )
      )

      options = cli.send(:effective_options)

      expect(options[:file_prefix]).to eq("lib")
      expect(options[:minimum_churn]).to eq(10)
      expect(options[:ignore]).to eq("spec")
      expect(options[:start_ago]).to eq("1m")
      expect(options[:verbose]).to be true
    end

    it "does not override config values with nil CLI options" do
      options = cli.send(:effective_options)

      expect(options[:verbose]).to be_nil
      expect(options[:type]).to be_nil
    end
  end
end
