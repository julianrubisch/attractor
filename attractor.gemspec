# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'attractor/version'

Gem::Specification.new do |spec|
  spec.name          = 'attractor'
  spec.version       = Attractor::VERSION
  spec.authors       = ['Julian Rubisch']
  spec.email         = ['julian@julianrubisch.at']

  spec.summary       = 'Churn vs Complexity Chart Generator'
  spec.description   = <<-DESCRIPTION
    Many authors (Michael Feathers, Sandi Metz) have shown that an evaluation of
    churn vs complexity of files in software projects provide a valuable metric
    towards code quality. This is another take on the matter, for ruby code, using the
    `churn` and `flog` projects.
  DESCRIPTION
  spec.homepage = 'https://github.com/julianrubisch/attractor'
  spec.licenses = ['MIT']

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/julianrubisch/attractor'
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['changelog_uri'] = 'https://github.com/julianrubisch/attractor/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(src|tmp|test|spec|features|\.github)/}) ||
        %w[.all-contributorsrc .rspec .rspec_status .travis.yml].include?(f)
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'churn', '>= 1.0.4'
  spec.add_dependency 'descriptive_statistics'
  spec.add_dependency 'flog', '~> 4.0'
  spec.add_dependency 'launchy'
  spec.add_dependency 'listen', '~> 3.0'
  spec.add_dependency 'rack-livereload'
  spec.add_dependency 'sinatra'
  spec.add_dependency 'thor'
  spec.add_dependency 'tilt'

  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'autoprefixer-rails'
  spec.add_development_dependency 'bootstrap', '~> 4.3.1'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'cucumber'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rake'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'sassc'
  spec.add_development_dependency 'standard'
  spec.add_development_dependency 'structured_changelog'
end
