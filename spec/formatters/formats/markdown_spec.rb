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

  describe "with sections and collapsed table" do
    let(:report) do
      Attractor::Formatters::Report.new(
        title: "main..feature",
        columns: %i[file_path delta],
        rows: [
          {file_path: "lib/new.rb", complexity_base: nil, complexity_head: 6.0, delta: 6.0},
          {file_path: "lib/gone.rb", complexity_base: 4.0, complexity_head: nil, delta: -4.0},
          {file_path: "lib/ok.rb", complexity_base: 5.0, complexity_head: 6.0, delta: 1.0}
        ],
        sections: [
          {title: "Stats", columns: %i[language score trend], rows: [{language: "rb", score: "10.0 (from 8.0)", trend: "📈 +25.0%"}]},
          {title: "Trends", columns: ["", :most_improved, :largest_declines], rows: [{"" => "rb", :most_improved => "none", :largest_declines => "lib/ok.rb (+1.0)"}]}
        ],
        collapsed_table: true
      )
    end

    it "renders sections before the main table" do
      output = described_class.new.call(report)

      expect(output).to include("## main..feature")
      expect(output).to include("### Stats")
      expect(output).to include("| language | score | trend |")
      expect(output).to include("| rb | 10.0 (from 8.0) | 📈 +25.0% |")
      expect(output).to include("### Trends")

      stats_position = output.index("### Stats")
      table_position = output.index("| file_path | delta |")
      expect(stats_position).to be < table_position
    end

    it "wraps the main table in a details block" do
      output = described_class.new.call(report)

      expect(output).to include("<details>")
      expect(output).to include("<summary>All files</summary>")
      expect(output).to include("</details>")
    end

    it "marks new and deleted files in the delta cell" do
      output = described_class.new.call(report)

      expect(output).to include("| lib/new.rb | new |")
      expect(output).to include("| lib/gone.rb | deleted |")
      expect(output).to include("| lib/ok.rb | 1.0 |")
    end
  end
end
