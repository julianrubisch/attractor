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

  def fn(name, long_name: name, ccn: 1, start_line: 1, end_line: 1)
    Attractor::Lizard::Function.new(name, long_name, ccn, 1, start_line, end_line)
  end

  it "defaults the type from the language" do
    expect(calculator.type).to eq("Swift")
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

  it "keys overloads by their signature so a key survives line shifts" do
    allow(Attractor::Lizard).to receive(:analyze).and_return([
      fn("card", long_name: "card _ cart : Cart", start_line: 32),
      fn("card", long_name: "card _ cart : Cart , tip : Double", ccn: 4, start_line: 50)
    ])

    expect(calculator.calculate.first.details.keys).to eq(["card _ cart : Cart", "card _ cart : Cart , tip : Double"])
  end

  it "falls back to the start line only when signatures collide too" do
    allow(Attractor::Lizard).to receive(:analyze).and_return([
      fn("card", long_name: "card _ cart : Cart", start_line: 32),
      fn("card", long_name: "card _ cart : Cart", start_line: 50)
    ])

    expect(calculator.calculate.first.details.keys).to eq(["card _ cart : Cart@32", "card _ cart : Cart@50"])
  end

  it "scores a file without functions as zero with empty details" do
    allow(Attractor::Lizard).to receive(:analyze).and_return([])

    value = calculator.calculate.first

    expect(value.complexity).to eq(0)
    expect(value.details).to eq({})
  end

  it "passes the file extension through to churn" do
    expect(::Churn::ChurnCalculator).to receive(:new).with(hash_including(file_extension: "swift")).and_return(churn_calc_instance)
    allow(Attractor::Lizard).to receive(:analyze).and_return([])

    calculator.calculate
  end
end

RSpec.describe Attractor::LizardCalculator, "key stability" do
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

  def fn(name, long_name: name, start_line: 1)
    Attractor::Lizard::Function.new(name, long_name, 1, 1, start_line, start_line)
  end

  it "keeps a unique function's key when its line moves" do
    allow(Attractor::Lizard).to receive(:analyze).and_return([fn("total", start_line: 6)])
    before = calculator.calculate.first.details.keys

    allow(Attractor::Lizard).to receive(:analyze).and_return([fn("total", start_line: 40)])
    after = calculator.calculate.first.details.keys

    expect(after).to eq(before)
  end

  it "keeps overload keys when their lines move" do
    allow(Attractor::Lizard).to receive(:analyze).and_return([
      fn("card", long_name: "card _ cart : Cart", start_line: 32),
      fn("card", long_name: "card _ cart : Cart , tip : Double", start_line: 50)
    ])
    before = calculator.calculate.first.details.keys

    allow(Attractor::Lizard).to receive(:analyze).and_return([
      fn("card", long_name: "card _ cart : Cart", start_line: 90),
      fn("card", long_name: "card _ cart : Cart , tip : Double", start_line: 120)
    ])
    after = calculator.calculate.first.details.keys

    expect(after).to eq(before)
  end
end
