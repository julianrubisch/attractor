require "attractor/formatters/report"
require "attractor/formatters/formats/json"

RSpec.describe Attractor::Formatters::Formats::JSON do
  let(:report) do
    Attractor::Formatters::Report.new(
      title: "Title",
      columns: %i[a b],
      rows: [{a: 1, b: 2}],
      metadata: {key: "value"},
      footer: "Footer"
    )
  end

  it "renders the report as json" do
    output = described_class.new.call(report)
    parsed = JSON.parse(output, symbolize_names: true)

    expect(parsed[:title]).to eq("Title")
    expect(parsed[:key]).to eq("value")
    expect(parsed[:rows]).to eq([{a: 1, b: 2}])
    expect(parsed[:footer]).to eq("Footer")
  end

  it "uses the configured rows_key" do
    custom_report = Attractor::Formatters::Report.new(
      title: "Title",
      columns: %i[a],
      rows: [{a: 1}],
      rows_key: :items
    )

    output = described_class.new.call(custom_report)
    parsed = JSON.parse(output, symbolize_names: true)

    expect(parsed[:items]).to eq([{a: 1}])
    expect(parsed).not_to have_key(:rows)
  end

  it "omits nil footer" do
    report = Attractor::Formatters::Report.new(
      title: "Title",
      columns: %i[a],
      rows: [{a: 1}]
    )

    output = described_class.new.call(report)
    parsed = JSON.parse(output, symbolize_names: true)

    expect(parsed).not_to have_key(:footer)
  end

  it "groups rows when group_by is set" do
    grouped_report = Attractor::Formatters::Report.new(
      title: "Title",
      columns: %i[type file_path],
      rows: [{type: "rb", file_path: "a.rb"}, {type: "rb", file_path: "b.rb"}, {type: "js", file_path: "a.js"}],
      group_by: :type
    )

    output = described_class.new.call(grouped_report)
    parsed = JSON.parse(output, symbolize_names: true)

    expect(parsed[:rows]).to eq({
      rb: [{type: "rb", file_path: "a.rb"}, {type: "rb", file_path: "b.rb"}],
      js: [{type: "js", file_path: "a.js"}]
    })
  end
end
