require "attractor/formatters/formatter"
require "attractor/formatters/targets/console"
require "attractor/formatters/targets/diff"
require "attractor/formatters/formats/json"
require "attractor/formatters/formats/table"
require "attractor/formatters/formats/markdown"

RSpec.describe Attractor::Formatters::Formatter do
  describe "console target" do
    let(:value) { Attractor::Value.new(file_path: "lib/foo.rb", churn: 3, complexity: 10.5) }
    let(:calc_dbl) { double("Calculator", calculate: [value]) }

    it "composes with json format" do
      formatter = described_class.new(
        target: Attractor::Formatters::Targets::Console.new,
        format: Attractor::Formatters::Formats::JSON.new
      )
      output = formatter.call({"rb" => calc_dbl})
      parsed = JSON.parse(output, symbolize_names: true)

      expect(parsed[:title]).to eq("Calculated churn and complexity")
      expect(parsed[:rows][:rb].first[:file_path]).to eq("lib/foo.rb")
    end

    it "composes with table format" do
      formatter = described_class.new(
        target: Attractor::Formatters::Targets::Console.new,
        format: Attractor::Formatters::Formats::Table.new
      )
      output = formatter.call({"rb" => calc_dbl})

      expect(output).to include("Calculated churn and complexity")
      expect(output).to include("lib/foo.rb")
    end
  end

  describe "diff target" do
    let(:data) do
      {
        base_ref: "main",
        head_ref: "feature",
        total_score_base: 100,
        total_score_head: 150,
        trend: 50,
        files: [{file_path: "lib/foo.rb", complexity_base: 10.0, complexity_head: 15.0, delta: 5.0}]
      }
    end

    it "composes with json format" do
      formatter = described_class.new(
        target: Attractor::Formatters::Targets::Diff.new,
        format: Attractor::Formatters::Formats::JSON.new
      )
      output = formatter.call(data)
      parsed = JSON.parse(output, symbolize_names: true)

      expect(parsed[:title]).to include("Complexity diff")
      expect(parsed[:files].first[:file_path]).to eq("lib/foo.rb")
    end

    it "composes with markdown format" do
      formatter = described_class.new(
        target: Attractor::Formatters::Targets::Diff.new,
        format: Attractor::Formatters::Formats::Markdown.new
      )
      output = formatter.call(data)

      expect(output).to include("# Complexity diff between main and feature")
    end
  end
end
