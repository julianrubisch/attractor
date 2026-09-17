require "attractor/formatters/report"

RSpec.describe Attractor::Formatters::Report do
  it "stores report attributes" do
    report = described_class.new(
      title: "Title",
      metadata: {key: "value"},
      columns: %i[a b],
      rows: [{a: 1, b: 2}],
      footer: "Footer",
      group_by: :a,
      rows_key: :items
    )

    expect(report.title).to eq("Title")
    expect(report.metadata).to eq({key: "value"})
    expect(report.columns).to eq(%i[a b])
    expect(report.rows).to eq([{a: 1, b: 2}])
    expect(report.footer).to eq("Footer")
    expect(report.group_by).to eq(:a)
    expect(report.rows_key).to eq(:items)
  end

  it "defaults rows_key to :rows" do
    report = described_class.new(title: "Title", columns: %i[a], rows: [{a: 1}])
    expect(report.rows_key).to eq(:rows)
  end
end
