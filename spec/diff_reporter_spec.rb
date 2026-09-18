require "json"
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

  it "composes a diff formatter" do
    reporter = described_class.new(format: :json)
    expect { reporter.report(data) }.to output(/"title":"Complexity diff between main and feature"/).to_stdout
    expect { reporter.report(data) }.to output(/"files":\[/).to_stdout
  end
end
