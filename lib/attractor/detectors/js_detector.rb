module Attractor
  class JsDetector < BaseDetector
    def detect
      package_json_exists?
    end
    
    def package_json_exists?
      File.exist? File.expand_path("package.json", Dir.pwd)
    end
  end 
end
