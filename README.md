# Attractor ![build status](https://travis-ci.org/julianrubisch/attractor.svg?branch=master) <img src="https://user-images.githubusercontent.com/4352208/65411858-3dc84200-ddee-11e9-99b6-c9cdbeb533c5.png" width="32">

![image](https://user-images.githubusercontent.com/4352208/65392349-4419d800-dd74-11e9-8dad-d84e21da09e3.png)

Many authors ([Michael Feathers](https://www.agileconnection.com/article/getting-empirical-about-refactoring), [Sandi Metz](https://www.sandimetz.com/blog/2017/9/13/breaking-up-the-behemoth)) have shown that an evaluation of churn vs complexity of files in software projects provide a valuable metric towards code quality. This is another take on the matter, for ruby code, using the `churn` and `flog` projects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'attractor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install attractor

## Usage

To create a HTML report in `attractor_output/index.html`, try
    
    $ attractor report

If you'd like to specify a directory, use the file prefix option:

    $ attractor report --file_prefix app/models

Or shorter:

    $ attractor report -p app/models

Watch for file changes:

    $ attractor report -p app/models --watch

Serve at http://localhost:7890:

    $ attractor serve -p app/models

Enable rack-livereload:

    $ attractor serve -p app/models --watch

### Live Reloading

If you have `guard-livereload` (or a similar service) running on your project, you can leverage the hot reloading functionality by specifying `--watch|-w`. Attractor will then live-reload the browser window when a file watched by `guard-livereload` changes.

## CLI Commands and Options

Print a simple output to console:

    $ attractor calc
    $   --file_prefix|-p app/models
    $   --watch|-w

Generate a full report

    $ attractor report 
    $   --file_prefix|-p app/models
    $   --watch|-w

Serve the output on http://localhost:7890

    $ attractor serve
    $   --file_prefix|-p app/models
    $   --watch|-w

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/julianrubisch/attractor.

## Social

[Twitter](https://twitter.com/AttractorGem)

## Logo Attribution
[Black Hole by Eynav Raphael from the Noun Project](https://thenounproject.com/term/black-hole/1043893)
