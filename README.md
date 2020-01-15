# Attractor ![build status](https://travis-ci.org/julianrubisch/attractor.svg?branch=master) <img src="https://user-images.githubusercontent.com/4352208/65411858-3dc84200-ddee-11e9-99b6-c9cdbeb533c5.png" width="32">
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-3-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

![attractor_v0 6 1](https://user-images.githubusercontent.com/4352208/67033292-b41e4280-f115-11e9-8c91-81b3bea4451c.gif)

Many authors ([Michael Feathers](https://www.agileconnection.com/article/getting-empirical-about-refactoring), [Sandi Metz](https://www.sandimetz.com/blog/2017/9/13/breaking-up-the-behemoth)) have shown that an evaluation of churn vs complexity of files in software projects provide a valuable metric towards code quality. This is another take on the matter, for ruby code, using the `churn` and `flog` projects.

Here's an [article on medium](https://medium.com/better-programming/why-i-made-my-own-code-quality-tool-c44b40ceaafd) explaining the approach in greater detail.

## Table of Contents

  * [Installation](#installation)
  * [Usage](#usage)
    + [Live Reloading](#live-reloading)
  * [CI Usage](#ci-usage)
    + [Github Action](#github-action)
    + [Gitlab Example](#gitlab-example)
  * [CLI Commands and Options](#cli-commands-and-options)
  * [Development](#development)
  * [Contributing](#contributing)
  * [Social](#social)
  * [Logo Attribution](#logo-attribution)

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

Check javascript:

    $ attractor report -p app/javascript -t js

Watch for file changes:

    $ attractor report -p app/models --watch

Serve at http://localhost:7890:

    $ attractor serve -p app/models

Enable rack-livereload:

    $ attractor serve -p app/models --watch

### Live Reloading

If you have `guard-livereload` (or a similar service) running on your project, you can leverage the hot reloading functionality by specifying `--watch|-w`. Attractor will then live-reload the browser window when a file watched by `guard-livereload` changes.

## CI Usage

To use this CLI in a CI environment, use the `--ci` option, which will suppress automatic opening of a browser window.

### Github Action

There is a dedicated [Github Action](https://github.com/julianrubisch/attractor-action) that will compile Attractor's output. Here's the action on the [Marketplace](https://github.com/marketplace/actions/attractor-action).

### Gitlab Example

The simplest use case is to store the `attractor_output` directory as an artifact.

```yml
attractor:
  stage: your-stage-label
  image: ruby:latest
  script:
    - gem install attractor
    - attractor report --ci
  artifacts:
    when: on_success
    paths:
      - attractor_output
```

Alternatively, 

## CLI Commands and Options

Print a simple output to console:

    $ attractor calc
    $   --file_prefix|-p app/models
    $   --type|-t rb|js
    $   --watch|-w
    $   --start_ago|-s  (e.g. 5y, 3m, 7w)
    $   --minimum_churn|-c (minimum times a file must have changed to be processed)

Generate a full report

    $ attractor report 
    $   --file_prefix|-p app/models
    $   --type|-t rb|js
    $   --watch|-w
    $   --no-open-browser|--ci
    $   --start_ago|-s  (e.g. 5y, 3m, 7w)
    $   --minimum_churn|-c (minimum times a file must have changed to be processed)

Serve the output on http://localhost:7890

    $ attractor serve
    $   --file_prefix|-p app/models
    $   --watch|-w
    $   --no-open-browser|--ci
    $   --start_ago|-s  (e.g. 5y, 3m, 7w)
    $   --minimum_churn|-c (minimum times a file must have changed to be processed)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/julianrubisch/attractor.

## Social

[Twitter](https://twitter.com/AttractorGem)

[Patreon](https://www.patreon.com/user?u=24747270)

## Logo Attribution
[Black Hole by Eynav Raphael from the Noun Project](https://thenounproject.com/term/black-hole/1043893)

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="http://www.julianrubisch.at"><img src="https://avatars0.githubusercontent.com/u/4352208?v=4" width="100px;" alt=""/><br /><sub><b>Julian Rubisch</b></sub></a><br /><a href="https://github.com/julianrubisch/attractor/commits?author=julianrubisch" title="Code">💻</a> <a href="https://github.com/julianrubisch/attractor/commits?author=julianrubisch" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/olimart"><img src="https://avatars3.githubusercontent.com/u/547754?v=4" width="100px;" alt=""/><br /><sub><b>Olivier</b></sub></a><br /><a href="#maintenance-olimart" title="Maintenance">🚧</a></td>
    <td align="center"><a href="https://www.andrewmason.me/"><img src="https://avatars1.githubusercontent.com/u/18423853?v=4" width="100px;" alt=""/><br /><sub><b>Andrew Mason</b></sub></a><br /><a href="https://github.com/julianrubisch/attractor/commits?author=andrewmcodes" title="Code">💻</a> <a href="https://github.com/julianrubisch/attractor/pulls?q=is%3Apr+reviewed-by%3Aandrewmcodes" title="Reviewed Pull Requests">👀</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
