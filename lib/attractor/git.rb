# frozen_string_literal: true

require "fileutils"
require "tmpdir"
require "rugged"

module Attractor
  module Git
    def self.repo
      @repo ||= Rugged::Repository.discover(".")
    end

    def self.validate_ref!(ref)
      repo.rev_parse(ref)
    rescue Rugged::ReferenceError
      raise ArgumentError, "Invalid git ref: #{ref}"
    end

    def self.diff_files(base_ref, head_ref)
      base_commit = repo.merge_base(base_ref, head_ref)
      head_commit = repo.rev_parse(head_ref)

      repo.diff(base_commit, head_commit).deltas.map { |delta| delta.new_file[:path] }.uniq
    end

    class Worktree
      attr_reader :path

      def initialize(ref)
        @ref = ref
        @path = Dir.mktmpdir("attractor-diff-#{ref}-")
      end

      def checkout
        success = system("git", "worktree", "add", "-f", @path, @ref, out: File::NULL, err: File::NULL)
        raise "Failed to create git worktree for #{@ref} at #{@path}" unless success

        self
      end

      def cleanup
        system("git", "worktree", "remove", "-f", @path, out: File::NULL, err: File::NULL)
        FileUtils.rm_rf(@path)
      end

      def chdir(&block)
        Dir.chdir(@path, &block)
      end
    end
  end
end
