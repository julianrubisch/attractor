require "attractor/reporters/console_reporter"

RSpec.describe Attractor::ConsoleReporter do
  let(:value) { Attractor::Value.new(file_path: "lib/foo.rb", churn: 3, complexity: 10) }
  let(:calc_dbl) { double("Calculator", type: "rb", calculate: [value]) }
  let(:calculators) { {"rb" => calc_dbl} }

  it "composes a console formatter" do
    reporter = described_class.new(format: :json, calculators: calculators)
    expect { reporter.report }.to output(/"title":"Calculated churn and complexity"/).to_stdout
  end
end
