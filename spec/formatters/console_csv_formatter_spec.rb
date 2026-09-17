require "attractor/formatters/console_csv_formatter"

RSpec.describe Attractor::Formatters::ConsoleCSVFormatter do
  let(:value) { Attractor::Value.new(file_path: "lib/foo.rb", churn: 3, complexity: 10.5) }
  let(:data) do
    [
      {type: "rb", values: [value], refactor_files: ["lib/foo.rb"]}
    ]
  end

  it "formats csv" do
    output = described_class.new.call(data)

    expect(output).to include("file_path,score,complexity,churn,type,refactor")
    expect(output).to include("lib/foo.rb,31.5,10.5,3,rb,true")
  end
end
