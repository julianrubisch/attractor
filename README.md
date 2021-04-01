<!-- MARKDOWN LINKS & IMAGES -->
<!-- Shields -->
[forks-shield]: https://img.shields.io/github/forks/julianrubisch/attractor.svg?style=flat-square
[forks-url]: https://github.com/julianrubisch/attractor/network/members
[stars-shield]: https://img.shields.io/github/stars/julianrubisch/attractor.svg?style=flat-square
[stars-url]: https://github.com/julianrubisch/attractor/stargazers
[issues-shield]: https://img.shields.io/github/issues/julianrubisch/attractor.svg?style=flat-square
[issues-url]: https://github.com/julianrubisch/attractor/issues
[license-shield]: https://img.shields.io/github/license/julianrubisch/attractor.svg?style=flat-square
[license-url]: https://github.com/julianrubisch/attractor/blob/master/LICENSE
[twitter-url]: https://twitter.com/AttractorGem
[twitter-shield]: https://img.shields.io/twitter/follow/AttractorGem?style=social
[build-status]: https://travis-ci.org/julianrubisch/attractor.svg?branch=master
[twitter-shield]: https://img.shields.io/twitter/follow/AttractorGem?style=social
[ruby-tests-action-shield]: https://github.com/julianrubisch/attractor/workflows/Ruby%20Tests/badge.svg
<!-- Media -->
[demo-gif]: https://user-images.githubusercontent.com/4352208/67033292-b41e4280-f115-11e9-8c91-81b3bea4451c.gif
[logo-source]: https://thenounproject.com/term/black-hole/1043893
<!-- References -->
[medium-article]: https://medium.com/better-programming/why-i-made-my-own-code-quality-tool-c44b40ceaafd
[sandi-metz-article]: https://www.sandimetz.com/blog/2017/9/13/breaking-up-the-behemoth
[michael-feathers-article]: https://www.agileconnection.com/article/getting-empirical-about-refactoring
[bundler]: https://bundler.io
[rack-livereload]: https://github.com/johnbintz/rack-livereload
[guard-livereload]: https://github.com/guard/guard-livereload
[attractor-action]: https://github.com/julianrubisch/attractor-action
[attractor-action-marketplace]: https://github.com/marketplace/actions/attractor-action
[repo]: https://github.com/julianrubisch/attractor

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/julianrubisch/attractor">
    <img src="https://user-images.githubusercontent.com/4352208/65411858-3dc84200-ddee-11e9-99b6-c9cdbeb533c5.png" alt="Logo" width="80" height="80">
  </a>
  <h2 align="center">Attractor</h2>
  <p align="center">A code complexity metrics visualization and exploration tool for Ruby and JavaScript</p>

---

<!-- PROJECT SHIELDS -->
![Build Status][build-status]
![Ruby Tests Action Status][ruby-tests-action-shield]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![Twitter follow][twitter-shield]][twitter-url]
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-4-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

  <a href="https://www.patreon.com/user?u=24747270"><img src="https://c5.patreon.com/external/logo/become_a_patron_button@2x.png" alt="Become a Patron!" width="160" /></a>
</div>

<!-- GIF -->
![attractor_v0 6 1][demo-gif]

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Introduction](#introduction)
- [Installation](#installation)
- [Usage](#usage)
  - [Live Reloading](#live-reloading)
- [CI Usage](#ci-usage)
  - [Github Action](#github-action)
  - [Gitlab Example](#gitlab-example)
- [CLI Commands and Options](#cli-commands-and-options)
- [Development](#development)
- [Contributing](#contributing)
- [Logo Attribution](#logo-attribution)
- [Contributors ✨](#contributors-%e2%9c%a8)

## Introduction

Many authors ([Michael Feathers][michael-feathers-article], [Sandi Metz][sandi-metz-article]) have shown that an evaluation of churn vs complexity of files in software projects provide a valuable metric towards code quality. This is another take on the matter, for ruby code, using the `churn` and `flog` projects.

Here's an [article on medium][medium-article] explaining the approach in greater detail.

## Installation

Attractor's installation is standard for a Ruby gem:

```sh
gem install attractor
```

You'll also want to install some plugins to go along with the main gem:

```sh
gem install attractor-ruby # https://github.com/julianrubisch/attractor-ruby
gem install attractor-javascript # https://github.com/julianrubisch/attractor-javascript
```

You will most likely want to install Attractor using [Bundler][bundler]:

```ruby
gem 'attractor'
gem 'attractor-ruby'
gem 'attractor-javascript'
```

And then execute:

```sh
bundle
```

## Usage

To create a HTML report in `attractor_output/index.html`:

```sh
attractor report
```

If you'd like to specify a directory, use the file prefix option:

```sh
attractor report --file_prefix app/models
```

Or shorter:

```sh
attractor report -p app/models
```

Check JavaScript:

```sh
attractor report -p app/javascript -t js
```

Watch for file changes:

```sh
attractor report -p app/models --watch
```

Serve at `http://localhost:7890`:

```sh
attractor serve -p app/models
```

Enable [rack-livereload][rack-livereload]:

```sh
attractor serve -p app/models --watch
```

_Make sure you prefix these commands with `bundle exec` if you are using Bundler._

### Live Reloading

If you have [guard-livereload][guard-livereload] (or a similar service) running on your project, you can leverage the hot reloading functionality by specifying `--watch|-w`. Attractor will then live-reload the browser window when a file watched by `guard-livereload` changes.

## CI Usage

To use this CLI in a CI environment, use the `--ci` option, which will suppress automatic opening of a browser window.

### Github Action

There is a dedicated [Github Action][attractor-action] that will compile Attractor's output.

You can quickly integrate it into your action's workflow by grabbing it on the [Marketplace][attractor-action-marketplace].

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

## CLI Commands and Options

Print a simple output to console:

```sh
attractor calc
  --file_prefix|-p app/models
  --type|-t rb|js
  --watch|-w
  --start_ago|-s  (e.g. 5y, 3m, 7w)
  --minimum_churn|-c (minimum times a file must have changed to be processed)
  --ignore|-i 'spec/*_spec.rb,db/schema.rb,tmp'
```

Generate a full report

```sh
attractor report
  --file_prefix|-p app/models
  --type|-t rb|js
  --watch|-w
  --no-open-browser|--ci
  --start_ago|-s  (e.g. 5y, 3m, 7w)
  --minimum_churn|-c (minimum times a file must have changed to be processed)
  --ignore|-i 'spec/*_spec.rb,db/schema.rb,tmp'
```

Serve the output on `http://localhost:7890`

```sh
attractor serve
  --file_prefix|-p app/models
  --watch|-w
  --no-open-browser|--ci
  --start_ago|-s  (e.g. 5y, 3m, 7w)
  --minimum_churn|-c (minimum times a file must have changed to be processed)
  --ignore|-i 'spec/*_spec.rb,db/schema.rb,tmp'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To run all tests, run `bin/test`. You can run the specs by themselves with `bundle exec rspec`, and the cucumber features with `bundle exec cucumber`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on [GitHub][repo].

## Logo Attribution

[Black Hole by Eynav Raphael from the Noun Project][logo-source]

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="http://www.julianrubisch.at"><img src="https://avatars0.githubusercontent.com/u/4352208?v=4" width="100px;" alt=""/><br /><sub><b>Julian Rubisch</b></sub></a><br /><a href="https://github.com/julianrubisch/attractor/commits?author=julianrubisch" title="Code">💻</a> <a href="https://github.com/julianrubisch/attractor/commits?author=julianrubisch" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/olimart"><img src="https://avatars3.githubusercontent.com/u/547754?v=4" width="100px;" alt=""/><br /><sub><b>Olivier</b></sub></a><br /><a href="#maintenance-olimart" title="Maintenance">🚧</a></td>
    <td align="center"><a href="https://www.andrewmason.me/"><img src="https://avatars1.githubusercontent.com/u/18423853?v=4" width="100px;" alt=""/><br /><sub><b>Andrew Mason</b></sub></a><br /><a href="https://github.com/julianrubisch/attractor/commits?author=andrewmcodes" title="Code">💻</a> <a href="https://github.com/julianrubisch/attractor/pulls?q=is%3Apr+reviewed-by%3Aandrewmcodes" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/julianrubisch/attractor/commits?author=andrewmcodes" title="Documentation">📖</a></td>
    <td align="center"><a href="https://www.ombulabs.com"><img src="https://avatars2.githubusercontent.com/u/17584?v=4" width="100px;" alt=""/><br /><sub><b>Ernesto Tagwerker</b></sub></a><br /><a href="https://github.com/julianrubisch/attractor/commits?author=etagwerker" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
