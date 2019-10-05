# frozen_string_literal: true

require 'pry'
require 'rack/livereload'
require 'rack'
require 'sinatra/base'

module Attractor
  # skeleton sinatra app
  class AttractorApp < Sinatra::Base
    def initialize(reporter)
      super
      @reporter = reporter
    end

    get '/javascripts/index.js' do
      @serve_static = false
      @values = @reporter.values
      erb File.read(File.expand_path('../../../app/assets/javascripts/index.js.erb', __dir__)), content_type: 'text/javascript'
    end

    enable :static
    set :public_folder, File.expand_path('../../../app/assets', __dir__)

    get '/' do
      erb File.read(File.expand_path('../../../app/views/index.html.erb', __dir__))
    end

    get '/values' do
      @reporter.values.to_json
    end

    get '/suggestions' do
      threshold = params[:t] || 95
      @reporter.suggestions(threshold).to_json
    end
  end

  # serving the HTML locally
  class SinatraReporter < BaseReporter
    def report
      super

      app = AttractorApp.new(self)

      puts 'Serving attractor at http://localhost:7890'
      Launchy.open('http://localhost:7890')

      Rack::Handler::WEBrick.run app, Port: 7890
    end

    def watch
      @suggestions = @suggester.suggest

      app = AttractorApp.new(self)

      puts 'Serving attractor at http://localhost:7890'
      Launchy.open('http://localhost:7890')

      Rack::Handler::WEBrick.run Rack::LiveReload.new(app), Port: 7890
    end
  end
end
