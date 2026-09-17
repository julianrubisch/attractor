require "attractor/formatters/diff_json_formatter"

RSpec.describe Attractor::Formatters::DiffJSONFormatter do
  let(:data) do
    {
      base_ref: "main",
      head_ref: "feature",
      total_score_base: 100,
      total_score_head: 150,
      trend: 50,
      files: [
        {file_path: "lib/foo.rb", complexity_base: 10.0, complexity_head: 15.0, delta: 5.0}
      ]
    }
  end

  it "formats diff json" do
    output = described_class.new.call(data)
    parsed = JSON.parse(output, symbolize_names: true)

    expect(parsed[:base_ref]).to eq("main")
    expect(parsed[:files].first[:file_path]).to eq("lib/foo.rb")
  end
end
