require "attractor/git"

RSpec.describe Attractor::Git do
  describe ".validate_ref!" do
    let(:repo) { instance_double(Rugged::Repository) }

    before do
      allow(described_class).to receive(:repo).and_return(repo)
    end

    it "does not raise for valid refs" do
      allow(repo).to receive(:rev_parse).with("main").and_return(double)

      expect { described_class.validate_ref!("main") }.not_to raise_error
    end

    it "raises ArgumentError for invalid refs" do
      allow(repo).to receive(:rev_parse).with("invalid").and_raise(Rugged::ReferenceError)

      expect { described_class.validate_ref!("invalid") }.to raise_error(ArgumentError, /Invalid git ref/)
    end
  end

  describe ".diff_files" do
    let(:repo) { instance_double(Rugged::Repository) }
    let(:base_commit) { double("base_commit") }
    let(:head_commit) { double("head_commit") }
    let(:diff) { double("diff") }
    let(:delta) { double("delta", new_file: {path: "lib/foo.rb"}) }

    before do
      allow(described_class).to receive(:repo).and_return(repo)
      allow(repo).to receive(:merge_base).with("base", "head").and_return(base_commit)
      allow(repo).to receive(:rev_parse).with("head").and_return(head_commit)
      allow(repo).to receive(:diff).with(base_commit, head_commit).and_return(diff)
      allow(diff).to receive(:deltas).and_return([delta, delta])
    end

    it "returns unique file paths changed between refs" do
      expect(described_class.diff_files("base", "head")).to eq(["lib/foo.rb"])
    end
  end

  describe Attractor::Git::Worktree do
    let(:worktree) { described_class.new("main") }

    before do
      allow(Dir).to receive(:mktmpdir).and_return("/tmp/attractor-diff-main-xxx")
    end

    it "creates a temp directory" do
      expect(worktree.path).to eq("/tmp/attractor-diff-main-xxx")
    end

    it "checks out a git worktree" do
      allow(worktree).to receive(:system).and_return(true)

      expect(worktree).to receive(:system).with("git", "worktree", "add", "-f", "/tmp/attractor-diff-main-xxx", "main", out: File::NULL, err: File::NULL)
      worktree.checkout
    end

    it "raises when checkout fails" do
      allow(worktree).to receive(:system).and_return(false)

      expect { worktree.checkout }.to raise_error(RuntimeError, /Failed to create git worktree/)
    end

    it "cleans up the worktree" do
      allow(worktree).to receive(:system).and_return(true)
      allow(FileUtils).to receive(:rm_rf)

      expect(worktree).to receive(:system).with("git", "worktree", "remove", "-f", "/tmp/attractor-diff-main-xxx", out: File::NULL, err: File::NULL)
      worktree.cleanup
    end
  end
end
