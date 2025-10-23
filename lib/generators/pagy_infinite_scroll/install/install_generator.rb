# frozen_string_literal: true

require 'rails/generators/base'

module PagyInfiniteScroll
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc "Install Pagy Infinite Scroll into your application"

      def create_initializer
        template "initializer.rb", "config/initializers/pagy_infinite_scroll.rb"
      end

      def add_javascript_import
        if using_importmap?
          add_importmap_pin
        elsif using_jsbundling?
          add_jsbundling_import
        else
          say "Please manually import the Stimulus controller in your JavaScript setup", :yellow
        end
      end

      def show_post_install_message
        say "\n"
        say "Pagy Infinite Scroll installed successfully!", :green
        say "\n"
        say "Next steps:", :yellow
        say "  1. Make sure you have Pagy gem installed: gem 'pagy'"
        say "\n"

        if using_importmap?
          say "  2. Importmap setup (already configured!):", :green
          say "     - Pin added to config/importmap.rb"
          say "     - Import added to app/javascript/application.js"
          say "     - Controller auto-registers with Stimulus on page load"
          say "     - No manual registration needed!"
        elsif using_jsbundling?
          say "  2. jsbundling setup:", :yellow
          say "     Copy the controller to your app:"
          say "       cp $(bundle show pagy_infinite_scroll)/app/assets/javascripts/pagy_infinite_scroll/infinite_scroll_controller.js app/javascript/controllers/pagy_infinite_scroll_controller.js"
          say "\n"
          say "     Then register in app/javascript/controllers/index.js:"
          say "       import PagyInfiniteScrollController from './pagy_infinite_scroll_controller'"
          say "       application.register('pagy-infinite-scroll', PagyInfiniteScrollController)"
          say "\n"
          say "     Finally run: yarn build (or npm run build)"
        else
          say "  2. Manual setup required", :yellow
          say "     See documentation for your JavaScript setup"
        end

        say "\n"
        say "  3. Use in your controllers: pagy_infinite_scroll(collection)"
        say "  4. See full documentation: https://github.com/hassanharoon86/pagy_infinite_scroll"
        say "\n"
      end

      private

      def using_importmap?
        File.exist?("config/importmap.rb")
      end

      def using_jsbundling?
        File.exist?("package.json") && (
          File.exist?("app/javascript/application.js") ||
          File.exist?("app/javascript/packs/application.js")
        )
      end

      def add_importmap_pin
        # Pin the standalone importmap-compatible controller
        append_to_file "config/importmap.rb" do
          "\n# Pagy Infinite Scroll - Standalone controller (auto-registers with Stimulus)\npin 'pagy_infinite_scroll_controller', to: 'pagy_infinite_scroll_controller.js'\n"
        end

        # Add import to application.js if it exists
        if File.exist?("app/javascript/application.js")
          append_to_file "app/javascript/application.js" do
            "\n// Pagy Infinite Scroll - Auto-registers with Stimulus\nimport 'pagy_infinite_scroll_controller'\n"
          end
        end

        say "\n"
        say "Importmap configuration added!", :green
        say "The controller will auto-register with Stimulus when loaded.", :green
        say "\n"
      end

      def add_jsbundling_import
        say "For jsbundling, you'll need to manually register the controller", :yellow
        say "See the post-install message above for instructions", :yellow
      end
    end
  end
end
