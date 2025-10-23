# frozen_string_literal: true

require_relative "lib/pagy_infinite_scroll/version"

Gem::Specification.new do |spec|
  spec.name = "pagy_infinite_scroll"
  spec.version = PagyInfiniteScroll::VERSION
  spec.authors = ["Hassan Haroon"]
  spec.email = ["hassanharoon86@gmail.com"]

  spec.summary = "Infinite scroll pagination for Rails using Pagy and Stimulus"
  spec.description = "A Rails gem that adds infinite scroll functionality to any Rails application using Pagy for efficient pagination and Stimulus for smooth frontend interactions. Features include automatic lazy loading, state preservation, AJAX support, and customizable behavior."
  spec.homepage = "https://github.com/hassanharoon86/pagy_infinite_scroll"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/hassanharoon86/pagy_infinite_scroll"
  spec.metadata["changelog_uri"] = "https://github.com/hassanharoon86/pagy_infinite_scroll/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "pagy", ">= 6.0"
  spec.add_dependency "rails", ">= 7.0"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-rails", "~> 6.0"
  spec.add_development_dependency "sqlite3", "~> 1.4"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
