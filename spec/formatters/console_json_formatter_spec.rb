require "attractor/formatters/console_json_formatter"

RSpec.describe Attractor::Formatters::ConsoleJSONFormatter do
  let(:value) { Attractor::Value.new(file_path: "lib/foo.rb", churn: 3, complexity: 10.5, details: [{method: "foo"}], history: [["abc", "commit"]]) }
  let(:data) do
    [
      {type: "rb", values: [value], refactor_files: ["lib/foo.rb"]}
    ]
  end

  it "formats json" do
    output = described_class.new.call(data)
    parsed = JSON.parse(output, symbolize_names: true)

    expect(parsed[:rb]).to be_an(Array)
    expect(parsed[:rb].first[:file_path]).to eq("lib/foo.rb")
    expect(parsed[:rb].first[:refactor]).to be true
  end
end
