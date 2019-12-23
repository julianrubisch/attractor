module Attractor
  class RubyDetector < BaseDetector
    def detect
      gemfile_exists?
    end
    
    def gemfile_exists?
      File.exist? File.expand_path("Gemfile", Dir.pwd)
    end
  end 
end
