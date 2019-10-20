RSpec.describe Attractor::BaseCalculator do
  let(:churn_calc_instance) { instance_double(::Churn::ChurnCalculator) }

  before do
    allow(::Churn::ChurnCalculator).to receive(:new).and_return(churn_calc_instance)
  end
  
  it 'yields control with the change from churn' do
    changes = [{ times_changed: 5, file_path: 'lib/test.rb' }]
    allow(churn_calc_instance).to receive(:report).and_return(churn: { changes: changes })
    calculator = described_class.new
    calculator.calculate do |change|
      [7, { some_method: 5, other_method: 2 }]
    end

    expect { |b| calculator.calculate(&b) }.to yield_with_args(changes.first)
  end
end
