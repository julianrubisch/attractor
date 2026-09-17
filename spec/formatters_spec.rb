require "attractor/formatters"

RSpec.describe Attractor::Formatters::Formatter do
  describe "console target" do
    let(:value) { Attractor::Value.new(file_path: "lib/foo.rb", churn: 3, complexity: 10.5) }
    let(:calc_dbl) { double("Calculator", calculate: [value]) }

    it "composes with json format" do
      formatter = described_class.new(target: :console, format: :json)
      output = formatter.call({"rb" => calc_dbl})
      parsed = JSON.parse(output, symbolize_names: true)

      expect(parsed[:title]).to eq("Calculated churn and complexity")
      expect(parsed[:rows][:rb].first[:file_path]).to eq("lib/foo.rb")
    end

    it "composes with table format" do
      formatter = described_class.new(target: :console, format: :table)
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
      formatter = described_class.new(target: :diff, format: :json)
      output = formatter.call(data)
      parsed = JSON.parse(output, symbolize_names: true)

      expect(parsed[:title]).to include("Complexity diff")
      expect(parsed[:files].first[:file_path]).to eq("lib/foo.rb")
    end

    it "composes with markdown format" do
      formatter = described_class.new(target: :diff, format: :markdown)
      output = formatter.call(data)

      expect(output).to include("# Complexity diff between main and feature")
    end
  end

  it "raises for unknown target" do
    expect { described_class.new(target: :unknown, format: :json) }.to raise_error(ArgumentError, /Unknown target/)
  end

  it "raises for unknown format" do
    expect { described_class.new(target: :diff, format: :unknown) }.to raise_error(ArgumentError, /Unknown format/)
  end
end
