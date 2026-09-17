require "attractor/formatters/console_table_formatter"

RSpec.describe Attractor::Formatters::ConsoleTableFormatter do
  let(:value) { Attractor::Value.new(file_path: "lib/foo.rb", churn: 3, complexity: 10.5) }
  let(:data) do
    [
      {type: "rb", values: [value], refactor_files: []}
    ]
  end

  it "formats a table" do
    output = described_class.new.call(data)

    expect(output).to include("Calculated churn and complexity")
    expect(output).to include("rb")
    expect(output).to include("lib/foo.rb")
    expect(output).to include("Suggestions for refactorings:")
  end
end
