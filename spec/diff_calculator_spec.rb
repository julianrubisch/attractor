require "attractor/diff_calculator"

RSpec.describe Attractor::DiffCalculator do
  let(:base_value) { Attractor::Value.new(file_path: "lib/foo.rb", churn: 3, complexity: 10, details: [{method: "foo", complexity: 5}]) }
  let(:head_value) { Attractor::Value.new(file_path: "lib/foo.rb", churn: 4, complexity: 15, details: [{method: "foo", complexity: 7}]) }
  let(:base_calculator) { double("BaseCalculator", calculate: [base_value]) }
  let(:head_calculator) { double("HeadCalculator", calculate: [head_value]) }
  let(:base_calculators) { {"rb" => base_calculator} }
  let(:head_calculators) { {"rb" => head_calculator} }

  let(:calculator) do
    described_class.new(base_ref: "base", head_ref: "head")
  end

  before do
    allow(calculator).to receive(:rev_parse).with("base").and_return("abc123")
    allow(calculator).to receive(:rev_parse).with("head").and_return("def456")
    allow(calculator).to receive(:default_files).and_return(["lib/foo.rb"])

    allow(Dir).to receive(:mktmpdir).with("attractor-diff-base-").and_return("/tmp/attractor-diff-base-xxx")
    allow(Dir).to receive(:mktmpdir).with("attractor-diff-head-").and_return("/tmp/attractor-diff-head-xxx")

    allow(calculator).to receive(:create_worktree)
    allow(calculator).to receive(:remove_worktree)
    allow(Attractor::Cache).to receive(:reset!)
    allow(Dir).to receive(:chdir).and_yield
    allow(Attractor).to receive(:calculators_for_type).and_return(base_calculators, head_calculators)
  end

  it "validates refs and creates worktrees for both sides" do
    expect(calculator).to receive(:create_worktree).with("/tmp/attractor-diff-base-xxx", "base")
    expect(calculator).to receive(:create_worktree).with("/tmp/attractor-diff-head-xxx", "head")

    calculator.calculate
  end

  it "returns diff data with complexity deltas" do
    result = calculator.calculate

    expect(result[:base_ref]).to eq("base")
    expect(result[:head_ref]).to eq("head")
    expect(result[:files].size).to eq(1)

    row = result[:files].first
    expect(row[:file_path]).to eq("lib/foo.rb")
    expect(row[:complexity_base]).to eq(10)
    expect(row[:complexity_head]).to eq(15)
    expect(row[:delta]).to eq(5.0)
    expect(row[:churn]).to eq(4)
    expect(row[:score_head]).to eq(60)
  end

  it "ranks rows by absolute delta descending" do
    small_base = Attractor::Value.new(file_path: "lib/small.rb", churn: 1, complexity: 2)
    small_head = Attractor::Value.new(file_path: "lib/small.rb", churn: 1, complexity: 3)
    large_base = Attractor::Value.new(file_path: "lib/large.rb", churn: 1, complexity: 5)
    large_head = Attractor::Value.new(file_path: "lib/large.rb", churn: 1, complexity: 100)

    allow(calculator).to receive(:default_files).and_return(["lib/small.rb", "lib/large.rb"])
    allow(Attractor).to receive(:calculators_for_type).and_return(
      {"rb" => double(calculate: [small_base, large_base])},
      {"rb" => double(calculate: [small_head, large_head])}
    )

    result = calculator.calculate
    expect(result[:files].map { |row| row[:file_path] }).to eq(["lib/large.rb", "lib/small.rb"])
  end

  it "marks files new in head with nil complexity_base" do
    new_head = Attractor::Value.new(file_path: "lib/new.rb", churn: 1, complexity: 8)
    allow(calculator).to receive(:default_files).and_return(["lib/new.rb"])
    allow(Attractor).to receive(:calculators_for_type).and_return(
      {"rb" => double(calculate: [])},
      {"rb" => double(calculate: [new_head])}
    )

    result = calculator.calculate
    row = result[:files].first
    expect(row[:complexity_base]).to be_nil
    expect(row[:complexity_head]).to eq(8)
    expect(row[:delta]).to eq(8.0)
  end

  it "marks files deleted in head with nil complexity_head" do
    deleted_base = Attractor::Value.new(file_path: "lib/deleted.rb", churn: 1, complexity: 8)
    allow(calculator).to receive(:default_files).and_return(["lib/deleted.rb"])
    allow(Attractor).to receive(:calculators_for_type).and_return(
      {"rb" => double(calculate: [deleted_base])},
      {"rb" => double(calculate: [])}
    )

    result = calculator.calculate
    row = result[:files].first
    expect(row[:complexity_base]).to eq(8)
    expect(row[:complexity_head]).to be_nil
    expect(row[:delta]).to eq(-8.0)
  end

  it "computes total scores and trend" do
    result = calculator.calculate

    expect(result[:total_score_base]).to eq(30)
    expect(result[:total_score_head]).to eq(60)
    expect(result[:trend]).to eq(30)
  end

  it "uses the provided file list instead of git diff" do
    calculator_with_files = described_class.new(base_ref: "base", head_ref: "head", files: ["lib/bar.rb"])
    allow(calculator_with_files).to receive(:rev_parse).with("base").and_return("abc123")
    allow(calculator_with_files).to receive(:rev_parse).with("head").and_return("def456")
    allow(calculator_with_files).to receive(:create_worktree)
    allow(calculator_with_files).to receive(:remove_worktree)

    bar_base = Attractor::Value.new(file_path: "lib/bar.rb", churn: 1, complexity: 5)
    bar_head = Attractor::Value.new(file_path: "lib/bar.rb", churn: 1, complexity: 7)
    allow(Attractor).to receive(:calculators_for_type).and_return(
      {"rb" => double(calculate: [bar_base])},
      {"rb" => double(calculate: [bar_head])}
    )

    result = calculator_with_files.calculate
    expect(result[:files].map { |row| row[:file_path] }).to eq(["lib/bar.rb"])
  end

  it "raises an error when base_ref is invalid" do
    bad_calculator = described_class.new(base_ref: "invalid", head_ref: "head")
    allow(bad_calculator).to receive(:rev_parse).with("invalid").and_raise(ArgumentError, "Invalid git ref: invalid")

    expect { bad_calculator.calculate }.to raise_error(ArgumentError, /Invalid git ref/)
  end

  it "passes options through to calculators" do
    opts = {file_prefix: "app", minimum_churn_count: 5, ignores: "spec", start_ago: "1y", verbose: true, type: "rb"}
    calc = described_class.new(base_ref: "base", head_ref: "head", **opts)
    allow(calc).to receive(:rev_parse).with("base").and_return("abc123")
    allow(calc).to receive(:rev_parse).with("head").and_return("def456")
    allow(calc).to receive(:default_files).and_return(["lib/foo.rb"])
    allow(calc).to receive(:create_worktree)
    allow(calc).to receive(:remove_worktree)

    expect(Attractor).to receive(:calculators_for_type).with("rb", hash_including(file_prefix: "app", minimum_churn_count: 5, ignores: "spec", start_ago: "1y", verbose: true, files: ["lib/foo.rb"])).twice.and_return(base_calculators, head_calculators)

    calc.calculate
  end
end
