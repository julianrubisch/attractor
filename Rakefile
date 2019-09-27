# frozen_string_literal: true

require 'autoprefixer-rails'
require 'bootstrap'
require 'bundler/gem_tasks'
require 'fileutils'
require 'rspec/core/rake_task'
require 'sassc'
require 'structured_changelog/tasks'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

task build: :assets

desc 'Preprocess assets'
task :assets do
  puts 'Preprocessing SCSS and JS files'

  puts 'Copying over bootstrap'

  FileUtils.cp_r Gem::Specification.find_by_name('bootstrap').gem_dir, 'tmp'

  sass = File.read(File.expand_path('./src/stylesheets/main.scss'))
  css = SassC::Engine.new(sass, style: :compressed).render
  prefixed = AutoprefixerRails.process(css)
  File.open(File.expand_path('./app/assets/stylesheets/main.css'), 'w') { |file| file.write(prefixed) }

  npm_output = `npm run build`
  puts npm_output
end
