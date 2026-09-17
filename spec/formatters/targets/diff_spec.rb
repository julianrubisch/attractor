require "attractor/formatters/targets/diff"

RSpec.describe Attractor::Formatters::Targets::Diff do
  let(:data) do
    {
      base_ref: "main",
      head_ref: "feature",
      total_score_base: 100,
      total_score_head: 150,
      trend: 50,
      files: [
        {file_path: "lib/foo.rb", complexity_base: 10.0, complexity_head: 15.0, delta: 5.0}
      ]
    }
  end

  it "produces a report from diff data" do
    report = described_class.new.call(data)

    expect(report).to be_a(Attractor::Formatters::Report)
    expect(report.title).to eq("Complexity diff between main and feature")
    expect(report.metadata).to eq({total_score_base: 100, total_score_head: 150, trend: 50})
    expect(report.rows.size).to eq(1)
    expect(report.rows.first[:file_path]).to eq("lib/foo.rb")
    expect(report.rows_key).to eq(:files)
  end
end
