require "attractor/formatters/report"
require "attractor/formatters/formats/markdown"

RSpec.describe Attractor::Formatters::Formats::Markdown do
  let(:report) do
    Attractor::Formatters::Report.new(
      title: "Title",
      columns: %i[name value],
      rows: [{name: "foo", value: 1}, {name: "bar", value: 2}],
      metadata: {total: 3},
      footer: "Footer"
    )
  end

  it "renders a markdown table with metadata and footer" do
    output = described_class.new.call(report)

    expect(output).to include("# Title")
    expect(output).to include("**Total:** 3")
    expect(output).to include("| name | value |")
    expect(output).to include("| foo | 1 |")
    expect(output).to include("Footer")
  end
end
