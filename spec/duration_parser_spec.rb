RSpec.describe Attractor::DurationParser do
  it 'converts weeks into days' do
    expect(Attractor::DurationParser.new('5w').duration).to eq(35)
  end

  it 'converts months into days' do
    expect(Attractor::DurationParser.new('3m').duration).to eq(90)
  end

  it 'converts years into days' do
    expect(Attractor::DurationParser.new('4y').duration).to eq(1460)
  end

  it 'converts a complex combination correctly' do
    expect(Attractor::DurationParser.new('1y2m7d').duration).to eq(432)
  end
end
