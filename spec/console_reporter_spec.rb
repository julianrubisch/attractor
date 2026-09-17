require "attractor/reporters/console_reporter"

RSpec.describe Attractor::ConsoleReporter do
  let(:calc_dbl) { double("Calculator", type: "rb", calculate: values) }
  let(:values) { [Attractor::Value.new(file_path: "lib/foo.rb", churn: 3, complexity: 10)] }
  let(:calculators) { {"rb" => calc_dbl} }

  it "uses the table formatter by default" do
    reporter = described_class.new(format: :table, calculators: calculators)
    expect_any_instance_of(Attractor::Formatters::ConsoleTableFormatter).to receive(:call).and_return("")

    reporter.report
  end

  it "uses the csv formatter when requested" do
    reporter = described_class.new(format: :csv, calculators: calculators)
    expect_any_instance_of(Attractor::Formatters::ConsoleCSVFormatter).to receive(:call).and_return("")

    reporter.report
  end

  it "uses the json formatter when requested" do
    reporter = described_class.new(format: :json, calculators: calculators)
    expect_any_instance_of(Attractor::Formatters::ConsoleJSONFormatter).to receive(:call).and_return("")

    reporter.report
  end

  it "prints the formatter output" do
    reporter = described_class.new(format: :json, calculators: calculators)
    allow_any_instance_of(Attractor::Formatters::ConsoleJSONFormatter).to receive(:call).and_return("{}")

    expect { reporter.report }.to output("{}\n").to_stdout
  end
end
