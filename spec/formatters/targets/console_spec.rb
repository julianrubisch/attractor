require "attractor/formatters/targets/console"

RSpec.describe Attractor::Formatters::Targets::Console do
  let(:value) { Attractor::Value.new(file_path: "lib/foo.rb", churn: 3, complexity: 10.5, details: [{method: "foo"}], history: [["abc", "commit"]]) }
  let(:calc_dbl) { double("Calculator", calculate: [value], type: "rb") }

  it "produces a report from calculators" do
    report = described_class.new.call({"rb" => calc_dbl})

    expect(report).to be_a(Attractor::Formatters::Report)
    expect(report.title).to eq("Calculated churn and complexity")
    expect(report.metadata).to eq({schema: 2})
    expect(report.columns).to eq(%i[file_path score complexity churn type refactor])
    expect(report.rows.size).to eq(1)
    expect(report.rows.first[:file_path]).to eq("lib/foo.rb")
    expect(report.rows.first[:type]).to eq("rb")
    expect(report.group_by).to eq(:type)
  end
end
