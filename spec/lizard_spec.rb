require "spec_helper"
require "attractor/lizard"

RSpec.describe Attractor::Lizard do
  after { described_class.reset! }

  describe ".parse" do
    let(:csv) do
      <<~CSV
        10,3,62,1,10,"total@6-15@App.swift","App.swift","total","total discount : Double?",6,15
        4,2,26,1,4,"add@17-20@App.swift","App.swift","add","add _ item : Item",17,20
      CSV
    end

    it "maps lizard's header-less CSV to functions" do
      functions = described_class.parse(csv)

      expect(functions.map(&:name)).to eq(%w[total add])
      expect(functions.first).to have_attributes(ccn: 3, nloc: 10, start_line: 6, end_line: 15, long_name: "total discount : Double?")
    end

    it "returns no functions for empty output" do
      expect(described_class.parse("")).to eq([])
    end
  end

  describe ".command" do
    it "honours ATTRACTOR_LIZARD" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("ATTRACTOR_LIZARD").and_return("python -m lizard")

      expect(described_class.command).to eq(["python", "-m", "lizard"])
    end

    it "prefers lizard on PATH, then uvx" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("ATTRACTOR_LIZARD").and_return(nil)
      allow(described_class).to receive(:executable?).with("lizard").and_return(false)
      allow(described_class).to receive(:executable?).with("uvx").and_return(true)

      expect(described_class.command).to eq(["uvx", "lizard"])
    end

    it "raises with an install hint when neither exists" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("ATTRACTOR_LIZARD").and_return(nil)
      allow(described_class).to receive(:executable?).and_return(false)

      expect { described_class.command }.to raise_error(Attractor::Error, /uvx lizard/)
    end
  end

  describe ".analyze" do
    it "runs the command with the language and parses the result" do
      allow(described_class).to receive(:command).and_return(["lizard"])
      status = instance_double(Process::Status, success?: true)
      allow(Open3).to receive(:capture3).with("lizard", "-l", "swift", "--csv", "App.swift")
        .and_return(['1,1,5,0,1,"f@1-1@App.swift","App.swift","f","f",1,1' + "\n", "", status])

      expect(described_class.analyze("App.swift", language: "swift").map(&:name)).to eq(["f"])
    end

    it "raises with stderr when lizard fails" do
      allow(described_class).to receive(:command).and_return(["lizard"])
      status = instance_double(Process::Status, success?: false)
      allow(Open3).to receive(:capture3).and_return(["", "boom", status])

      expect { described_class.analyze("App.swift", language: "swift") }.to raise_error(Attractor::Error, /boom/)
    end
  end
end
