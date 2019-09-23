# frozen_string_literal: true

require 'pry'
require 'rack/livereload'
require 'rack'
require 'sinatra/base'

module Attractor
  class AttractorApp < Sinatra::Base
    enable :static
    set :public_folder, File.expand_path('../../../app/assets', __dir__)

    get '/' do
      @suggestions = []
      erb File.read(File.expand_path('../../../app/views/index.html.erb', __dir__))
    end
  end

  # serving the HTML locally
  class SinatraReporter < Reporter
    def report
      super

      app = AttractorApp.new

      puts 'Serving attractor at http://localhost:7890'
      Launchy.open('http://localhost:7890')

      Rack::Handler::WEBrick.run app, Port: 7890
    end

    def watch
      @suggestions = @suggester.suggest

      app = AttractorApp.new

      puts 'Serving attractor at http://localhost:7890'
      Launchy.open('http://localhost:7890')

      Rack::Handler::WEBrick.run Rack::LiveReload.new(app), Port: 7890
    end
  end
end
