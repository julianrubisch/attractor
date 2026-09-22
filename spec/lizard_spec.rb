require "spec_helper"
require "attractor/lizard"

RSpec.describe Attractor::Lizard do
  after { described_class.reset! }

  # The env var is read at resolution time; setting it for real keeps the global ENV
  # untouched outside the example.
  def with_env(name, value)
    previous = ENV[name]
    ENV[name] = value
    yield
  ensure
    ENV[name] = previous
  end

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

    it "drops lines that are not full rows instead of inventing functions" do
      noisy = "WARNING: parse error in App.swift\n\n" + csv + "1 file analyzed.\n"

      expect(described_class.parse(noisy).map(&:name)).to eq(%w[total add])
    end

    it "keeps quoted commas inside names" do
      row = %(1,1,5,0,1,"f@1-1@a.js","a.js","foo, bar","foo, bar ( a , b )",1,1\n)

      expect(described_class.parse(row).first).to have_attributes(name: "foo, bar", long_name: "foo, bar ( a , b )")
    end

    it "scrubs invalid UTF-8 instead of raising" do
      row = %(1,1,5,0,1,"f@1-1@a.rb","a.rb","caf\xE9","caf\xE9 ( )",1,1\n).b

      expect(described_class.parse(row).first.name).to eq("caf?")
    end

    it "wraps unreadable CSV in Attractor::Error" do
      expect { described_class.parse(%(1,"unterminated\n), file_path: "a.rb") }
        .to raise_error(Attractor::Error, /unreadable CSV for a.rb/)
    end
  end

  describe ".command" do
    it "honours ATTRACTOR_LIZARD" do
      with_env("ATTRACTOR_LIZARD", "python -m lizard") do
        expect(described_class.command).to eq(["python", "-m", "lizard"])
      end
    end

    it "treats a blank ATTRACTOR_LIZARD as unset" do
      with_env("ATTRACTOR_LIZARD", "  ") do
        allow(described_class).to receive(:executable?).with("lizard").and_return(true)

        expect(described_class.command).to eq(["lizard"])
      end
    end

    it "prefers lizard on PATH over uvx" do
      with_env("ATTRACTOR_LIZARD", nil) do
        allow(described_class).to receive(:executable?).with("lizard").and_return(true)
        allow(described_class).to receive(:executable?).with("uvx").and_return(true)

        expect(described_class.command).to eq(["lizard"])
      end
    end

    it "falls back to uvx" do
      with_env("ATTRACTOR_LIZARD", nil) do
        allow(described_class).to receive(:executable?).with("lizard").and_return(false)
        allow(described_class).to receive(:executable?).with("uvx").and_return(true)

        expect(described_class.command).to eq(["uvx", "lizard"])
      end
    end

    it "raises with an install hint when neither exists" do
      with_env("ATTRACTOR_LIZARD", nil) do
        allow(described_class).to receive(:executable?).and_return(false)

        expect { described_class.command }.to raise_error(Attractor::Error, /uvx lizard/)
      end
    end
  end

  describe ".analyze" do
    it "runs the command with the language and parses the result" do
      allow(described_class).to receive(:command).and_return(["lizard"])
      status = instance_double(Process::Status, success?: true)
      allow(Open3).to receive(:capture3).with("lizard", "-l", "swift", "--csv", "App.swift")
        .and_return([%(1,1,5,0,1,"f@1-1@App.swift","App.swift","f","f",1,1\n), "", status])

      expect(described_class.analyze("App.swift", language: "swift").map(&:name)).to eq(["f"])
    end

    it "returns no functions for a file without any" do
      allow(described_class).to receive(:command).and_return(["lizard"])
      status = instance_double(Process::Status, success?: true)
      allow(Open3).to receive(:capture3).and_return(["", "", status])

      expect(described_class.analyze("Empty.swift", language: "swift")).to eq([])
    end

    it "raises with stderr when lizard fails" do
      allow(described_class).to receive(:command).and_return(["lizard"])
      status = instance_double(Process::Status, success?: false)
      allow(Open3).to receive(:capture3).and_return(["", "boom", status])

      expect { described_class.analyze("App.swift", language: "swift") }.to raise_error(Attractor::Error, /boom/)
    end
  end
end
