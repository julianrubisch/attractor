require "attractor/reporters/diff_reporter"

RSpec.describe Attractor::DiffReporter do
  let(:data) do
    {
      base_ref: "main",
      head_ref: "feature",
      total_score_base: 100,
      total_score_head: 150,
      trend: 50,
      files: []
    }
  end

  it "uses the table formatter by default" do
    reporter = described_class.new(format: :table)
    expect_any_instance_of(Attractor::Formatters::DiffTableFormatter).to receive(:call).with(data).and_return("")

    reporter.report(data)
  end

  it "uses the json formatter when requested" do
    reporter = described_class.new(format: :json)
    expect_any_instance_of(Attractor::Formatters::DiffJSONFormatter).to receive(:call).with(data).and_return("")

    reporter.report(data)
  end

  it "uses the markdown formatter when requested" do
    reporter = described_class.new(format: :markdown)
    expect_any_instance_of(Attractor::Formatters::DiffMarkdownFormatter).to receive(:call).with(data).and_return("")

    reporter.report(data)
  end

  it "prints the formatter output" do
    reporter = described_class.new(format: :json)
    allow_any_instance_of(Attractor::Formatters::DiffJSONFormatter).to receive(:call).with(data).and_return("{}")

    expect { reporter.report(data) }.to output("{}\n").to_stdout
  end
end
