# frozen_string_literal: true

module Attractor
  # HTML reporter
  class HtmlReporter < BaseReporter
    def report
      super

      puts 'Generating an HTML report'
      @serve_static = true

      FileUtils.mkdir_p './attractor_output'
      FileUtils.mkdir_p './attractor_output/stylesheets'
      FileUtils.mkdir_p './attractor_output/images'
      FileUtils.mkdir_p './attractor_output/javascripts'

      File.open('./attractor_output/images/attractor_logo.svg', 'w') { |file| file.write(logo) }
      File.open('./attractor_output/images/attractor_favicon.png', 'w') { |file| file.write(favicon) }
      File.open('./attractor_output/stylesheets/main.css', 'w') { |file| file.write(css) }
      File.open('./attractor_output/javascripts/index.pack.js', 'w') { |file| file.write(javascript_pack) }

      if @calculators.size > 1
        @calculators.each do |calc|
          @short_type = calc.first
          @values = calc.last.calculate
          suggester = Suggester.new(values)
          @suggestions = suggester.suggest

          File.open("./attractor_output/javascripts/index.#{@short_type}.js", 'w') { |file| file.write(javascript) }
          File.open("./attractor_output/index.#{@short_type}.html", 'w') { |file| file.write(render) }
          puts "Generated HTML report at #{File.expand_path './attractor_output/'}/index.#{@short_type}.html"
        end

        if @open_browser
          Launchy.open(File.expand_path("./attractor_output/index.#{@calculators.first.first}.html"))
          puts "Opening browser window..."
        end
      else
        File.open('./attractor_output/javascripts/index.js', 'w') { |file| file.write(javascript) }
        File.open('./attractor_output/index.html', 'w') { |file| file.write(render) }
        puts "Generated HTML report at #{File.expand_path './attractor_output/index.html'}"

        if @open_browser
          Launchy.open(File.expand_path('./attractor_output/index.html'))
          puts "Opening browser window..."
        end
      end

    end

    def logo
      File.read(File.expand_path('../../../app/assets/images/attractor_logo.svg', __dir__))
    end

    def favicon
      File.read(File.expand_path('../../../app/assets/images/attractor_favicon.png', __dir__))
    end

    def css
      File.read(File.expand_path('../../../app/assets/stylesheets/main.css', __dir__))
    end

    def javascript_pack
      File.read(File.expand_path('../../../app/assets/javascripts/index.pack.js', __dir__))
    end

    def javascript
      template = Tilt.new(File.expand_path('../../../app/assets/javascripts/index.js.erb', __dir__))
      template.render self
    end

    def render
      template = Tilt.new(File.expand_path('../../../app/views/index.html.erb', __dir__))
      template.render self
    end
  end
end
