# frozen_string_literal: true

module Attractor
  # HTML reporter
  class HtmlReporter < BaseReporter
    def report
      super

      puts "Generating an HTML report"
      @serve_static = true

      FileUtils.mkdir_p "./attractor_output"
      FileUtils.mkdir_p "./attractor_output/stylesheets"
      FileUtils.mkdir_p "./attractor_output/images"
      FileUtils.mkdir_p "./attractor_output/javascripts"

      File.write("./attractor_output/images/attractor_logo.svg", logo)
      File.write("./attractor_output/images/attractor_favicon.png", favicon)
      File.write("./attractor_output/stylesheets/main.css", css)
      File.write("./attractor_output/javascripts/index.pack.js", javascript_pack)

      if @calculators.size > 1
        @calculators.each do |calc|
          @short_type = calc.first
          suggester = Suggester.new(values(type: @short_type))
          @suggestions = suggester.suggest

          File.write("./attractor_output/javascripts/index.#{@short_type}.js", javascript)
          File.write("./attractor_output/index.#{@short_type}.html", render)
          puts "Generated HTML report at #{File.expand_path "./attractor_output/"}/index.#{@short_type}.html"
        end

        if @open_browser
          Launchy.open(File.expand_path("./attractor_output/index.#{@calculators.first.first}.html"))
          puts "Opening browser window..."
        end
      else
        File.write("./attractor_output/javascripts/index.js", javascript)
        File.write("./attractor_output/index.html", render)
        puts "Generated HTML report at #{File.expand_path "./attractor_output/index.html"}"

        if @open_browser
          Launchy.open(File.expand_path("./attractor_output/index.html"))
          puts "Opening browser window..."
        end
      end
    end

    def logo
      File.read(File.expand_path("../../../app/assets/images/attractor_logo.svg", __dir__))
    end

    def favicon
      File.read(File.expand_path("../../../app/assets/images/attractor_favicon.png", __dir__))
    end

    def css
      File.read(File.expand_path("../../../app/assets/stylesheets/main.css", __dir__))
    end

    def javascript_pack
      File.read(File.expand_path("../../../app/assets/javascripts/index.pack.js", __dir__))
    end

    def javascript
      template = Tilt.new(File.expand_path("../../../app/assets/javascripts/index.js.erb", __dir__))
      template.render self
    end

    def render
      template = Tilt.new(File.expand_path("../../../app/views/index.html.erb", __dir__))
      template.render self
    end
  end
end
