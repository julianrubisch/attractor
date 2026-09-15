RSpec.describe Attractor::BaseCalculator do
  let(:churn_calc_instance) { instance_double(::Churn::ChurnCalculator) }

  before do
    allow(::Churn::ChurnCalculator).to receive(:new).and_return(churn_calc_instance)
  end

  it "yields control with the change from churn" do
    changes = [{times_changed: 5, file_path: "lib/test.rb"}]
    allow(churn_calc_instance).to receive(:report).and_return(churn: {changes: changes})
    calculator = described_class.new
    calculator.calculate do |change|
      [7, {some_method: 5, other_method: 2}]
    end

    expect { |b| calculator.calculate(&b) }.to yield_with_args(changes.first)
  end

  describe "with an explicit file list" do
    let(:changes) do
      [
        {times_changed: 5, file_path: "lib/kept.rb"},
        {times_changed: 3, file_path: "lib/deleted.rb"}
      ]
    end

    before do
      allow(churn_calc_instance).to receive(:report).and_return(churn: {changes: changes})
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with("lib/kept.rb").and_return(true)
      allow(File).to receive(:exist?).with("lib/deleted.rb").and_return(false)
      allow(File).to receive(:exist?).with("lib/missing.rb").and_return(false)
      allow(Attractor::Cache).to receive(:read).and_return(nil)
      allow(Attractor::Cache).to receive(:write)
      allow(Attractor::Cache).to receive(:persist!)
    end

    it "only reports files in the list" do
      calculator = described_class.new(files: ["lib/kept.rb", "lib/missing.rb"])

      result = calculator.calculate do |change|
        (change[:file_path] == "lib/kept.rb") ? [7, {}] : [nil, {}]
      end

      expect(result.map(&:file_path)).to contain_exactly("lib/kept.rb", "lib/missing.rb")
    end

    it "reports deleted listed files with nil complexity" do
      calculator = described_class.new(files: ["lib/deleted.rb"])

      result = calculator.calculate { |_change| [1, {}] }
      deleted = result.find { |value| value.file_path == "lib/deleted.rb" }

      expect(deleted).not_to be_nil
      expect(deleted.complexity).to be_nil
      expect(deleted.churn).to eq(3)
    end

    it "drops listed files that exist but have no churn" do
      allow(File).to receive(:exist?).with("lib/unknown.rb").and_return(true)
      calculator = described_class.new(files: ["lib/unknown.rb"])

      result = calculator.calculate { |_change| [1, {}] }

      expect(result).to be_empty
    end
  end
end
