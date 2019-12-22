require 'spec_helper'

RSpec.describe Attractor::JsDetector do
  it 'detects a present package.json in a React app' do
    allow(Dir).to receive(:pwd).and_return("#{RSPEC_FIXTURES_PATH}/sample-react-app")  

    expect(Attractor::JsDetector.new.detect).to eq(true)
  end
end
