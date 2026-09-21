require "spec_helper"
require "attractor/calculators/lizard_calculator"

RSpec.describe Attractor::LizardCalculator do
  let(:churn_calc_instance) { instance_double(::Churn::ChurnCalculator) }
  let(:calculator) { described_class.new(language: "swift", file_extension: "swift") }

  before do
    allow(::Churn::ChurnCalculator).to receive(:new).and_return(churn_calc_instance)
    allow(churn_calc_instance).to receive(:report).and_return(churn: {changes: [{times_changed: 3, file_path: "App.swift"}]})
    allow(Attractor::Cache).to receive(:read).and_return(nil)
    allow(Attractor::Cache).to receive(:write)
    allow(Attractor::Cache).to receive(:persist!)
    allow(calculator).to receive(:git_history_for_file).and_return([])
  end

  def fn(name, ccn:, start_line:, end_line:)
    Attractor::Lizard::Function.new(name: name, long_name: name, ccn: ccn, nloc: 1, start_line: start_line, end_line: end_line)
  end

  it "sums CCN into complexity and maps functions to details with locations" do
    allow(Attractor::Lizard).to receive(:analyze).with("App.swift", language: "swift").and_return([
      fn("total", ccn: 3, start_line: 6, end_line: 15),
      fn("add", ccn: 2, start_line: 17, end_line: 20)
    ])

    value = calculator.calculate.first

    expect(value.complexity).to eq(5)
    expect(value.details).to eq(
      "total" => {"score" => 3, "line" => 6, "end_line" => 15},
      "add" => {"score" => 2, "line" => 17, "end_line" => 20}
    )
  end

  it "keeps same-named functions apart by start line" do
    allow(Attractor::Lizard).to receive(:analyze).and_return([
      fn("card", ccn: 1, start_line: 32, end_line: 32),
      fn("card", ccn: 4, start_line: 50, end_line: 60)
    ])

    expect(calculator.calculate.first.details.keys).to eq(["card@32", "card@50"])
  end

  it "passes the file extension through to churn" do
    expect(::Churn::ChurnCalculator).to receive(:new).with(hash_including(file_extension: "swift")).and_return(churn_calc_instance)
    allow(Attractor::Lizard).to receive(:analyze).and_return([])

    calculator.calculate
  end
end
