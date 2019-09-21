# frozen_string_literal: true

require 'descriptive_statistics/safe'
require 'fileutils'
require 'launchy'
require 'rack'
require 'rack/livereload'
require 'tilt'

module Attractor
  # base reporter
  class Reporter
    extend Forwardable
    attr_accessor :values
    def_delegator :@watcher, :watch

    def initialize(file_prefix: '')
      @calculator = Calculator.new(file_prefix: file_prefix)
      @values = @calculator.calculate
      @suggester = Suggester.new(values)

      @watcher = Watcher.new(file_prefix, lambda do
        report
      end)
    end

    def report
      @suggestions = @suggester.suggest
    end

    def render
      'Attractor'
    end

    def serve
      @suggestions = @suggester.suggest
    end
  end

  # console reporter
  class ConsoleReporter < Reporter
    def report
      super
      puts 'Calculated churn and complexity'
      puts
      puts "file_path#{' ' * 53}complexity   churn"
      puts '-' * 80

      puts @values.map(&:to_s)

      puts
      puts 'Suggestions for refactorings:'
      @suggestions.each { |sug| puts sug.file_path }
      puts
    end
  end

  # HTML reporter
  class HtmlReporter < Reporter
    def report
      super

      puts 'Generating an HTML report'

      FileUtils.mkdir_p './attractor_output'

      css = File.read(File.expand_path('../../app/assets/stylesheets/main.css', __dir__))

      File.open('./attractor_output/main.css', 'w') { |file| file.write(css) }
      File.open('./attractor_output/index.html', 'w') { |file| file.write(render) }
      puts "Generated HTML report at #{File.expand_path './attractor_output/index.html'}"

      Launchy.open(File.expand_path('./attractor_output/index.html'))
    end

    def render
      template = Tilt.new(File.expand_path('../../app/views/index.html.erb', __dir__))
      template.render self
    end
  end

  # serving the HTML locally
  class RackReporter < Reporter
    def report
      super

      app = serve_via_rack

      Rack::Handler::WEBrick.run app, Port: 7890
    end

    def render
      template = Tilt.new(File.expand_path('../../app/views/index.html.erb', __dir__))
      template.render self
    end

    def watch
      @suggestions = @suggester.suggest

      app = serve_via_rack

      Rack::Handler::WEBrick.run Rack::LiveReload.new(app), Port: 7890
    end

    private

    def serve_via_rack
      app = lambda do |_env|
        [200, { 'Content-Type' => 'text/html' }, [render]]
      end

      puts 'Serving attractor at http://localhost:7890'
      Launchy.open('http://localhost:7890')

      app
    end
  end
end
