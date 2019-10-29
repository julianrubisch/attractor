RSpec.describe Attractor::BaseReporter do
  let(:values) { [{ churn: 6, complexity: 100, file_path: './test.rb' }] }
  let(:calc_dbl) { double('Calculator') }

  before do
    allow(calc_dbl).to receive(:calculate).and_return(values)
  end
 
  it 'renders something' do
    expect(described_class.new(calculators: { 'rb': calc_dbl }).render).to eq 'Attractor'
  end

  it 'allows injection of a calculator and calculates values' do
    reporter = described_class.new(calculators: { 'rb': calc_dbl })
    expect(reporter.values).to eq(values)
  end
end
