require "attractor/formatters/report"
require "attractor/formatters/formats/csv"

RSpec.describe Attractor::Formatters::Formats::CSV do
  let(:report) do
    Attractor::Formatters::Report.new(
      title: "Title",
      columns: %i[name value],
      rows: [{name: "foo", value: 1}, {name: "bar", value: 2}]
    )
  end

  it "renders csv rows" do
    output = described_class.new.call(report)

    expect(output).to include("name,value")
    expect(output).to include("foo,1")
    expect(output).to include("bar,2")
  end
end
