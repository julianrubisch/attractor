require "attractor/cache"

RSpec.describe Attractor::Cache do
  let(:cache_file) { "tmp/attractor-cache.json" }
  let(:value) do
    Attractor::Value.new(
      file_path: "lib/foo.rb",
      churn: 3,
      complexity: 10.5,
      details: {"foo" => {"score" => 5.0, "line" => 2, "end_line" => 4}},
      history: [["abc123", "initial commit"]]
    )
  end

  before do
    FileUtils.rm_f(cache_file)
    Attractor::Cache.reset!
  end

  after do
    FileUtils.rm_f(cache_file)
    Attractor::Cache.reset!
  end

  it "writes and reads values" do
    Attractor::Cache.write(file_path: "lib/foo.rb", value: value)
    Attractor::Cache.persist!
    Attractor::Cache.reset!

    cached = Attractor::Cache.read(file_path: "lib/foo.rb")

    expect(cached.file_path).to eq("lib/foo.rb")
    expect(cached.churn).to eq(3)
    expect(cached.complexity).to eq(10.5)
    expect(cached.details).to eq({"foo" => {"score" => 5.0, "line" => 2, "end_line" => 4}})
  end

  it "clears stale caches that lack a schema version" do
    File.write(cache_file, ::JSON.dump({"lib/foo.rb" => {"abc123" => {"churn" => 3, "complexity" => 10.5, "details" => {"foo" => 5.0}, "history" => []}}}))
    Attractor::Cache.reset!

    expect(Attractor::Cache.read(file_path: "lib/foo.rb")).to be_nil
  end

  it "clears stale caches with an outdated schema version" do
    File.write(cache_file, ::JSON.dump({"schema_version" => 1, "lib/foo.rb" => {"abc123" => {"churn" => 3, "complexity" => 10.5, "details" => {"foo" => 5.0}, "history" => []}}}))
    Attractor::Cache.reset!

    expect(Attractor::Cache.read(file_path: "lib/foo.rb")).to be_nil
  end
end
