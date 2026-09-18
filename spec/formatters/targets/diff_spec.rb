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
        {file_path: "lib/foo.rb", type: "rb", complexity_base: 10.0, complexity_head: 15.0, delta: 5.0, score_base: 30.0, score_head: 45.0, refactor_base: false, refactor_head: false},
        {file_path: "lib/bar.rb", type: "rb", complexity_base: 8.0, complexity_head: 4.0, delta: -4.0, score_base: 24.0, score_head: 12.0, refactor_base: true, refactor_head: false},
        {file_path: "lib/baz.rb", type: "rb", complexity_base: 5.0, complexity_head: 20.0, delta: 15.0, score_base: 15.0, score_head: 60.0, refactor_base: false, refactor_head: true},
        {file_path: "lib/new.rb", type: "rb", complexity_base: nil, complexity_head: 6.0, delta: 6.0, score_base: 0.0, score_head: 18.0, refactor_base: false, refactor_head: false},
        {file_path: "src/app.js", type: "js", complexity_base: 3.0, complexity_head: 5.0, delta: 2.0, score_base: 6.0, score_head: 10.0, refactor_base: false, refactor_head: false}
      ]
    }
  end

  it "produces a report from diff data" do
    report = described_class.new.call(data)

    expect(report).to be_a(Attractor::Formatters::Report)
    expect(report.title).to eq("Attractor: main..feature")
    expect(report.rows.size).to eq(5)
    expect(report.rows.first[:file_path]).to eq("lib/foo.rb")
    expect(report.rows_key).to eq(:files)
    expect(report.collapsed_table).to be true
  end

  describe "stats section" do
    it "builds per-language score and trend rows" do
      report = described_class.new.call(data)
      stats = report.sections.find { |section| section[:title] == "Stats" }

      expect(stats[:columns]).to eq(%i[language score trend])

      rb_stats = stats[:rows].find { |row| row[:language] == "rb" }
      expect(rb_stats[:score]).to eq("135.0 (from 69.0)")
      expect(rb_stats[:trend]).to match(/📈 \+95\.7%/)

      js_stats = stats[:rows].find { |row| row[:language] == "js" }
      expect(js_stats[:score]).to eq("10.0 (from 6.0)")
      expect(js_stats[:trend]).to match(/📈 \+66\.7%/)
    end

    it "guards against a zero base score" do
      report = described_class.new.call(data.merge(files: [
        {file_path: "lib/missing.rb", type: "rb", complexity_base: nil, complexity_head: nil, delta: 0.0, score_base: 0.0, score_head: 0.0, refactor_base: false, refactor_head: false}
      ]))

      stats = report.sections.find { |section| section[:title] == "Stats" }
      expect(stats[:rows].first[:trend]).to eq("0.0%")
    end
  end

  describe "trends section" do
    it "lists most improved and largest declines per language" do
      report = described_class.new.call(data)
      trends = report.sections.find { |section| section[:title] == "Trends" }

      expect(trends[:columns]).to eq(["", :most_improved, :largest_declines])

      rb_trends = trends[:rows].find { |row| row[""] == "rb" }
      expect(rb_trends[:most_improved]).to include("lib/bar.rb (-4.0)")
      expect(rb_trends[:largest_declines]).to include("lib/baz.rb (+15.0)")
      expect(rb_trends[:largest_declines]).to include("lib/foo.rb (+5.0)")
    end

    it "uses 'none' when there are no improved or declined files" do
      report = described_class.new.call(data.merge(files: [
        {file_path: "lib/flat.rb", type: "rb", complexity_base: 5.0, complexity_head: 5.0, delta: 0.0, score_base: 5.0, score_head: 5.0, refactor_base: false, refactor_head: false}
      ]))

      trends = report.sections.find { |section| section[:title] == "Trends" }
      expect(trends[:rows].first[:most_improved]).to eq("none")
      expect(trends[:rows].first[:largest_declines]).to eq("none")
    end
  end

  describe "to-dos section" do
    it "separates new refactoring candidates from refactored files" do
      report = described_class.new.call(data)
      todos = report.sections.find { |section| section[:title] == "To-dos" }

      expect(todos[:columns]).to eq(["", :new_refactoring_candidates, :refactored])

      rb_todos = todos[:rows].find { |row| row[""] == "rb" }
      expect(rb_todos[:new_refactoring_candidates]).to eq("lib/baz.rb")
      expect(rb_todos[:refactored]).to eq("lib/bar.rb")
    end

    it "uses 'none' when no refactor status flipped" do
      report = described_class.new.call(data.merge(files: [
        {file_path: "lib/stable.rb", type: "rb", complexity_base: 5.0, complexity_head: 5.0, delta: 0.0, score_base: 5.0, score_head: 5.0, refactor_base: false, refactor_head: false}
      ]))

      todos = report.sections.find { |section| section[:title] == "To-dos" }
      expect(todos[:rows].first[:new_refactoring_candidates]).to eq("none")
      expect(todos[:rows].first[:refactored]).to eq("none")
    end
  end
end
