# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'attractor/version'

Gem::Specification.new do |spec|
  spec.name          = 'attractor'
  spec.version       = Attractor::VERSION
  spec.authors       = ['Julian Rubisch']
  spec.email         = ['julian@julianrubisch.at']

  spec.summary       = 'Churn vs Complexity'
  spec.description   = 'Churn vs Complexity'
  spec.homepage = 'https://github.com/julianrubisch/attractor'

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/julianrubisch/attractor'
  spec.metadata['changelog_uri'] = 'https://github.com/julianrubisch/attractor/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'churn'
  spec.add_dependency 'descriptive_statistics'
  spec.add_dependency 'flog', '~> 4.0'
  spec.add_dependency 'thor'
  spec.add_dependency 'tilt'

  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'cucumber'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
