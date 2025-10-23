# Pagy Infinite Scroll Gem - Issues and Fixes Documentation

**Date:** October 23, 2025
**Version:** 0.1.0
**Status:** In Development - Not Production Ready

---

## 🚨 Current Issues

### 1. **Rails Engine Integration Issues**

**Problem:**
The engine is not properly set up to auto-load helpers and assets into the parent Rails application.

**Current Code:**
```ruby
# lib/pagy_infinite_scroll/engine.rb
class Engine < ::Rails::Engine
  isolate_namespace PagyInfiniteScroll

  initializer "pagy_infinite_scroll.assets" do |app|
    app.config.assets.paths << root.join("app/assets/javascripts")
    app.config.assets.precompile += %w[pagy_infinite_scroll/infinite_scroll_controller.js]
  end

  initializer "pagy_infinite_scroll.helpers" do
    ActiveSupport.on_load(:action_controller) do
      include PagyInfiniteScroll::ControllerHelper
    end

    ActiveSupport.on_load(:action_view) do
      include PagyInfiniteScroll::ViewHelper
    end
  end
end
```

**Issue:**
- The `isolate_namespace` might prevent proper helper loading
- Asset paths may not be correctly registered
- No guarantee that helpers are available when needed

**Fix:**
```ruby
# lib/pagy_infinite_scroll/engine.rb
module PagyInfiniteScroll
  class Engine < ::Rails::Engine
    # Don't isolate namespace to allow helpers to load into main app
    engine_name 'pagy_infinite_scroll'

    # Ensure assets are available
    initializer "pagy_infinite_scroll.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/assets/javascripts")
        app.config.assets.precompile += %w[pagy_infinite_scroll/infinite_scroll_controller.js]
      end
    end

    # Load helpers into ActionController and ActionView
    initializer "pagy_infinite_scroll.helpers" do
      ActiveSupport.on_load(:action_controller_base) do
        helper PagyInfiniteScroll::ViewHelper
        include PagyInfiniteScroll::ControllerHelper
      end
    end

    # Add a railtie for non-engine setup
    config.after_initialize do
      if defined?(ActionController::Base)
        ActionController::Base.include(PagyInfiniteScroll::ControllerHelper)
        ActionController::Base.helper(PagyInfiniteScroll::ViewHelper)
      end
    end
  end
end
```

---

### 2. **Missing Pagy Backend Include**

**Problem:**
The `ControllerHelper` includes `Pagy::Backend` but Pagy might not be loaded yet.

**Current Code:**
```ruby
# lib/pagy_infinite_scroll/controller_helper.rb
module PagyInfiniteScroll
  module ControllerHelper
    extend ActiveSupport::Concern

    included do
      include Pagy::Backend  # This might fail if Pagy isn't loaded
    end
  end
end
```

**Issue:**
- If Pagy gem hasn't been required yet, this will raise `uninitialized constant Pagy`
- No error handling for missing Pagy dependency

**Fix:**
```ruby
# lib/pagy_infinite_scroll/controller_helper.rb
module PagyInfiniteScroll
  module ControllerHelper
    extend ActiveSupport::Concern

    included do
      begin
        include Pagy::Backend
      rescue NameError
        raise "Pagy gem is required. Add 'gem \"pagy\"' to your Gemfile"
      end
    end

    # ... rest of the code
  end
end
```

**Better Fix - Add Railtie:**
```ruby
# lib/pagy_infinite_scroll/railtie.rb
require 'pagy'

module PagyInfiniteScroll
  class Railtie < Rails::Railtie
    initializer "pagy_infinite_scroll.configure_pagy" do
      # Ensure Pagy is loaded before our gem
      require 'pagy/extras/support' if defined?(Pagy)
    end
  end
end
```

---

### 3. **JavaScript/Stimulus Integration Issues**

**Problem:**
The Stimulus controller import path won't work with importmap or jsbundling.

**Current Code:**
```javascript
// app/assets/javascripts/pagy_infinite_scroll/index.js
import { application } from "@hotwired/stimulus"
import InfiniteScrollController from "./infinite_scroll_controller"

application.register("pagy-infinite-scroll", InfiniteScrollController)

export { InfiniteScrollController }
```

**Issues:**
- Assumes Stimulus `application` is globally available
- Path imports won't work with Rails asset pipeline
- No pin/import map configuration provided

**Fix Option 1 - For Import Maps:**

Create pin configuration:
```ruby
# lib/pagy_infinite_scroll/engine.rb (add this)
initializer "pagy_infinite_scroll.importmap", before: "importmap" do |app|
  if defined?(Importmap)
    app.config.importmap.paths << root.join("config/importmap.rb")
  end
end
```

```ruby
# config/importmap.rb (create this file in gem)
pin "pagy_infinite_scroll", to: "pagy_infinite_scroll/index.js"
pin "pagy_infinite_scroll/infinite_scroll_controller", to: "pagy_infinite_scroll/infinite_scroll_controller.js"
```

**Fix Option 2 - For JS Bundling:**

Provide standalone controller:
```javascript
// app/assets/javascripts/pagy_infinite_scroll/infinite_scroll_controller.js
// Don't auto-register, let users register manually

import { Controller } from "@hotwired/stimulus"

export default class PagyInfiniteScrollController extends Controller {
  // ... controller code
}

// Usage in host app:
// import PagyInfiniteScrollController from "pagy_infinite_scroll/infinite_scroll_controller"
// application.register("pagy-infinite-scroll", PagyInfiniteScrollController)
```

---

### 4. **Missing Installation Instructions**

**Problem:**
No clear setup instructions for different Rails configurations.

**Fix - Add INSTALLATION.md:**

```markdown
# Installation Guide

## Step 1: Add Gem

```ruby
# Gemfile
gem 'pagy_infinite_scroll'
gem 'pagy', '~> 6.0'  # Required dependency
```

## Step 2: Bundle Install

```bash
bundle install
```

## Step 3: JavaScript Setup

### For Import Maps:
```ruby
# config/importmap.rb
pin "pagy_infinite_scroll"
```

```javascript
// app/javascript/application.js
import "pagy_infinite_scroll"
```

### For JS Bundling (esbuild/webpack):
```javascript
// app/javascript/controllers/index.js
import { application } from "@hotwired/stimulus"
import PagyInfiniteScrollController from "pagy_infinite_scroll/infinite_scroll_controller"

application.register("pagy-infinite-scroll", PagyInfiniteScrollController)
```

## Step 4: Include Pagy in ApplicationController (if not already)

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Pagy::Backend
end
```

## Step 5: Use in Your Controllers

```ruby
class ProductsController < ApplicationController
  def index
    @pagy, @products = pagy_infinite_scroll(Product.all)

    respond_to do |format|
      format.html
      format.json do
        render json: pagy_infinite_scroll_json(@pagy, @products) { |p|
          { id: p.id, title: p.title }
        }
      end
    end
  end
end
```
```

---

### 5. **View Helper HTML Generation Issues**

**Problem:**
The `spinner_svg` method in view helper might not work correctly in all Rails versions.

**Current Code:**
```ruby
def spinner_svg
  content_tag :svg,
              class: 'animate-spin h-5 w-5',
              xmlns: 'http://www.w3.org/2000/svg',
              fill: 'none',
              viewBox: '0 0 24 24' do
    concat(tag(:circle, ...))
    concat(tag(:path, ...))
  end
end
```

**Issue:**
- `tag(:circle)` might need `tag.circle` in Rails 7+
- Self-closing tags need special handling

**Fix:**
```ruby
def spinner_svg
  <<~SVG.html_safe
    <svg class="animate-spin h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
    </svg>
  SVG
end
```

---

### 6. **Missing Gemspec Dependencies**

**Problem:**
The gemspec doesn't properly declare all dependencies.

**Current Code:**
```ruby
spec.add_dependency "pagy", ">= 6.0"
spec.add_dependency "rails", ">= 7.0"
```

**Missing:**
- No activesupport version specified
- No stimulus-rails suggested dependency
- No importmap-rails as optional dependency

**Fix:**
```ruby
# pagy_infinite_scroll.gemspec
spec.add_dependency "pagy", ">= 6.0"
spec.add_dependency "rails", ">= 7.0"
spec.add_dependency "activesupport", ">= 7.0"

# Development dependencies
spec.add_development_dependency "rspec", "~> 3.0"
spec.add_development_dependency "rspec-rails", "~> 6.0"
spec.add_development_dependency "sqlite3", "~> 1.4"
spec.add_development_dependency "capybara", "~> 3.0"
spec.add_development_dependency "stimulus-rails", "~> 1.0"
```

---

### 7. **No Generator for Setup**

**Problem:**
Users have to manually set up files. No Rails generator provided.

**Fix - Create Install Generator:**

```ruby
# lib/generators/pagy_infinite_scroll/install_generator.rb
module PagyInfiniteScroll
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def create_initializer
        template "initializer.rb", "config/initializers/pagy_infinite_scroll.rb"
      end

      def add_javascript_import
        if File.exist?("config/importmap.rb")
          append_to_file "config/importmap.rb", 'pin "pagy_infinite_scroll"\n'
        end

        if File.exist?("app/javascript/application.js")
          append_to_file "app/javascript/application.js", 'import "pagy_infinite_scroll"\n'
        end
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
```

```ruby
# lib/generators/pagy_infinite_scroll/templates/initializer.rb
PagyInfiniteScroll.configure do |config|
  # Number of items per page
  config.items_per_page = 50

  # Scroll threshold in pixels
  config.scroll_threshold = 100

  # Show loading indicator
  config.loading_indicator = true

  # Preserve state during infinite scroll
  config.preserve_state = true

  # Debounce delay for search (milliseconds)
  config.debounce_delay = 500
end
```

**Usage:**
```bash
rails generate pagy_infinite_scroll:install
```

---

### 8. **No Tests/Specs**

**Problem:**
No tests to verify functionality works.

**Fix - Create Basic Specs:**

```ruby
# spec/lib/pagy_infinite_scroll/controller_helper_spec.rb
require 'spec_helper'

RSpec.describe PagyInfiniteScroll::ControllerHelper do
  let(:controller_class) do
    Class.new do
      include PagyInfiniteScroll::ControllerHelper
    end
  end

  describe '#pagy_infinite_scroll' do
    it 'returns pagy object and records' do
      # Test implementation
    end
  end

  describe '#pagy_infinite_scroll_json' do
    it 'returns JSON with records and pagy data' do
      # Test implementation
    end
  end
end
```

---

## 🔧 Complete Fix Checklist

- [ ] Fix Rails Engine namespace isolation
- [ ] Add proper Pagy dependency checking
- [ ] Create importmap configuration
- [ ] Fix Stimulus controller registration
- [ ] Improve view helper HTML generation
- [ ] Update gemspec dependencies
- [ ] Create install generator
- [ ] Write comprehensive tests
- [ ] Add CI/CD configuration (GitHub Actions)
- [ ] Create detailed API documentation
- [ ] Add example Rails app
- [ ] Version and publish to RubyGems

---

## 📝 Priority Order

**Critical (Must Fix Before First Use):**
1. Rails Engine integration (#1)
2. Pagy Backend include (#2)
3. JavaScript/Stimulus integration (#3)

**Important (Should Fix Before v1.0):**
4. Installation instructions (#4)
5. View helper improvements (#5)
6. Gemspec dependencies (#6)

**Nice to Have:**
7. Install generator (#7)
8. Test coverage (#8)

---

## 🚀 Recommended Next Steps

1. **Test Locally First**
   ```ruby
   # In app-blue-sky/Gemfile
   gem 'pagy_infinite_scroll', path: '/Users/qbitech/sites/shhh/pagy_infinite_scroll/pagy_infinite_scroll'
   ```

2. **Fix Critical Issues** (1, 2, 3)

3. **Test in Real Application** (app-blue-sky)

4. **Iterate and Improve**

5. **Publish v0.1.0 as Beta**

6. **Gather Feedback**

7. **Release v1.0.0 Production Ready**

---

## 📚 Additional Resources

- [Pagy Documentation](https://ddnexus.github.io/pagy/)
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
- [Rails Engine Guide](https://guides.rubyonrails.org/engines.html)
- [Creating a Gem](https://guides.rubygems.org/make-your-own-gem/)

---

## 💡 Alternative Approach

Instead of fixing the gem immediately, you could:

**Option 1:** Keep the current implementation in app-blue-sky (already working)
**Option 2:** Extract to gem later after more real-world testing
**Option 3:** Create a simpler gem with just the core functionality

**Recommendation:** Use the working code in app-blue-sky for now, and refine the gem based on real usage patterns before publishing.

---

**Document Version:** 1.0
**Last Updated:** October 23, 2025
**Maintainer:** Hassan Haroon
