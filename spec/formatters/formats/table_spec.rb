require "attractor/formatters/report"
require "attractor/formatters/formats/table"

RSpec.describe Attractor::Formatters::Formats::Table do
  let(:report) do
    Attractor::Formatters::Report.new(
      title: "Title",
      columns: %i[name value],
      rows: [{name: "foo", value: 1}, {name: "bar", value: 22}],
      metadata: {total: 23},
      footer: "Footer"
    )
  end

  it "renders a table with metadata and footer" do
    output = described_class.new.call(report)

    expect(output).to include("Title")
    expect(output).to include("Total: 23")
    expect(output).to include("foo")
    expect(output).to include("bar")
    expect(output).to include("Footer")
  end
end
