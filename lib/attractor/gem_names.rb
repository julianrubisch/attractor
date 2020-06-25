module Attractor
  # from https://github.com/prontolabs/pronto/blob/master/lib/pronto/gem_names.rb
  class GemNames
    def to_a
      gems.map { |gem| gem.name.sub(/^attractor-/, '') }.uniq.sort
    end

    private

    def gems
      Gem::Specification.find_all.select do |gem|
        gem.name =~ /^attractor-/
      end.reject do |gem|
        gem.name =~ /attractor-rails/
      end
    end
  end
end
