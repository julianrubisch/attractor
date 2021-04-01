RSpec.describe Attractor::Watcher do
  it "can be instantiated" do
    described_class.new(".", "", -> {})
  end

  # it ":watch can be called" do
  #   described_class.new(".", -> {}).watch
  # end
end
