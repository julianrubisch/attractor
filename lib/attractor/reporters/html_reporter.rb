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
      File.open('./attractor_output/stylesheets/main.css', 'w') { |file| file.write(css) }
      File.open('./attractor_output/javascripts/index.js', 'w') { |file| file.write(javascript) }
      File.open('./attractor_output/javascripts/index.pack.js', 'w') { |file| file.write(javascript_pack) }
      
      File.open('./attractor_output/index.html', 'w') { |file| file.write(render) }
      puts "Generated HTML report at #{File.expand_path './attractor_output/index.html'}"

      Launchy.open(File.expand_path('./attractor_output/index.html'))
    end

    def logo
      File.read(File.expand_path('../../../app/assets/images/attractor_logo.svg', __dir__))
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
