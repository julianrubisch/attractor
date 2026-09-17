require "attractor/formatters/diff_table_formatter"

RSpec.describe Attractor::Formatters::DiffTableFormatter do
  let(:data) do
    {
      base_ref: "main",
      head_ref: "feature",
      total_score_base: 100,
      total_score_head: 150,
      trend: 50,
      files: [
        {
          file_path: "lib/foo.rb",
          complexity_base: 10.0,
          complexity_head: 15.0,
          delta: 5.0,
          churn: 4,
          score_head: 60,
          refactor_base: false,
          refactor_head: true
        },
        {
          file_path: "lib/bar.rb",
          complexity_base: 8.0,
          complexity_head: nil,
          delta: -8.0,
          churn: 0,
          score_head: nil,
          refactor_base: true,
          refactor_head: false
        }
      ]
    }
  end

  it "formats a diff table" do
    output = described_class.new.call(data)

    expect(output).to include("Complexity diff between main and feature")
    expect(output).to include("Total score: 100 → 150")
    expect(output).to include("lib/foo.rb")
    expect(output).to include("lib/bar.rb")
  end
end
