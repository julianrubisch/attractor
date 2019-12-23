require 'spec_helper'

RSpec.describe Attractor::RubyDetector do
  it 'detects a present Gemfile in a rails app' do
    allow(Dir).to receive(:pwd).and_return("#{RSPEC_FIXTURES_PATH}/rails_app_with_gemfile")  

    expect(Attractor::RubyDetector.new.detect).to eq(true)
  end

  it 'detects a present Gemfile in a rubygem' do
    allow(Dir).to receive(:pwd).and_return("#{RSPEC_FIXTURES_PATH}/gem-with-gemspec")  

    expect(Attractor::RubyDetector.new.detect).to eq(true)
  end
end
