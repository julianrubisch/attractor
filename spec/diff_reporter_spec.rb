require "attractor/reporters/diff_reporter"

RSpec.describe Attractor::DiffReporter do
  let(:data) do
    {
      base_ref: "main",
      head_ref: "feature",
      total_score_base: 100,
      total_score_head: 150,
      trend: 50,
      files: [
        {
          file_path: "lib/foo.rb",
          complexity_base: 10.0,
          complexity_head: 15.0,
          delta: 5.0,
          churn: 4,
          score_head: 60,
          refactor_base: false,
          refactor_head: true,
          details_base: [{method: "foo", complexity: 5}],
          details_head: [{method: "foo", complexity: 7}]
        },
        {
          file_path: "lib/bar.rb",
          complexity_base: 8.0,
          complexity_head: nil,
          delta: -8.0,
          churn: 0,
          score_head: nil,
          refactor_base: true,
          refactor_head: false,
          details_base: [],
          details_head: []
        }
      ]
    }
  end

  describe "table output" do
    it "prints a formatted table" do
      reporter = described_class.new(format: :table)

      expect { reporter.report(data) }.to output(/Complexity diff between main and feature/).to_stdout
      expect { reporter.report(data) }.to output(/Total score: 100 → 150/).to_stdout
      expect { reporter.report(data) }.to output(/lib\/foo.rb/).to_stdout
      expect { reporter.report(data) }.to output(/lib\/bar.rb/).to_stdout
    end
  end

  describe "json output" do
    it "prints the data as json" do
      reporter = described_class.new(format: :json)

      output = capture_stdout { reporter.report(data) }
      parsed = JSON.parse(output, symbolize_names: true)

      expect(parsed[:base_ref]).to eq("main")
      expect(parsed[:files].size).to eq(2)
      expect(parsed[:files].first[:file_path]).to eq("lib/foo.rb")
    end
  end

  describe "markdown output" do
    it "prints a markdown table" do
      reporter = described_class.new(format: :markdown)

      output = capture_stdout { reporter.report(data) }

      expect(output).to include("# Complexity diff between `main` and `feature`")
      expect(output).to include("| file_path | complexity_base | complexity_head | delta | churn | score_head | refactor_base | refactor_head |")
      expect(output).to include("| lib/foo.rb | 10.0 | 15.0 | 5.0 | 4 | 60 | false | true |")
    end
  end

  def capture_stdout
    old_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old_stdout
  end
end
