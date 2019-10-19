RSpec.describe Attractor::BaseReporter do
  it 'renders something' do
    expect(described_class.new.render).to eq 'Attractor'
  end

  it 'allows injection of a calculator and calculates values' do
    values = [{ churn: 6, complexity: 100, file_path: './test.rb' }]
    calc_dbl = double('Calculator')
    allow(calc_dbl).to receive(:calculate).and_return(values)
    
    reporter = described_class.new(calculators: [calc_dbl])
    expect(reporter.values).to eq(values)
  end
end
