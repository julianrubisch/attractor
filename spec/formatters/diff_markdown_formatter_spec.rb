require "attractor/formatters/diff_markdown_formatter"

RSpec.describe Attractor::Formatters::DiffMarkdownFormatter do
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
        }
      ]
    }
  end

  it "formats diff markdown" do
    output = described_class.new.call(data)

    expect(output).to include("# Complexity diff between `main` and `feature`")
    expect(output).to include("| lib/foo.rb | 10.0 | 15.0 | 5.0 | 4 | 60 | false | true |")
  end
end
