# frozen_string_literal: true

require "rack/livereload"
require "rack"
require "sinatra/base"

module Attractor
  # skeleton sinatra app
  class AttractorApp < Sinatra::Base
    def initialize(reporter)
      super
      @reporter = reporter
    end

    enable :static
    set :public_folder, File.expand_path("../../../app/assets", __dir__)
    set :show_exceptions, :after_handler

    get "/" do
      @types = @reporter.types
      erb File.read(File.expand_path("../../../app/views/index.html.erb", __dir__))
    end

    get "/file_prefix" do
      {file_prefix: @reporter.file_prefix}.to_json
    end

    get "/values" do
      type = params[:type] || "rb"
      @reporter.values(type: type).to_json
    end

    get "/suggestions" do
      threshold = params[:t] || 95
      type = params[:type] || "rb"
      @reporter.suggestions(quantile: threshold, type: type).to_json
    end

    error NoMethodError do
      {error: env["sinatra.error"].message}.to_json
    end
  end

  # serving the HTML locally
  class SinatraReporter < BaseReporter
    def report
      super

      app = AttractorApp.new(self)

      puts "Serving attractor at http://localhost:7890"

      if @open_browser
        Launchy.open("http://localhost:7890") if @open_browser
        puts "Opening browser window..."
      end

      Rack::Handler::WEBrick.run app, Port: 7890
    end

    def watch
      @suggestions = @suggester.suggest

      app = AttractorApp.new(self)

      puts "Serving attractor at http://localhost:7890"
      if @open_browser
        Launchy.open("http://localhost:7890")
        puts "Opening browser window..."
      end

      Rack::Handler::WEBrick.run Rack::LiveReload.new(app), Port: 7890
    end
  end
end
