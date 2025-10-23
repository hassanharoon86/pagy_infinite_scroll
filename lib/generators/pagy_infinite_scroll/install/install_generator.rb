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
        say "  2. Import the Stimulus controller in your JavaScript"

        if using_jsbundling?
          say "     Add to app/javascript/controllers/index.js:"
          say "     import PagyInfiniteScrollController from 'pagy_infinite_scroll'"
          say "     application.register('pagy-infinite-scroll', PagyInfiniteScrollController)"
        end

        say "  3. Use in your controllers: pagy_infinite_scroll(collection)"
        say "  4. See documentation: https://github.com/hassanharoon86/pagy_infinite_scroll"
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
        append_to_file "config/importmap.rb" do
          "\n# Pagy Infinite Scroll\npin 'pagy_infinite_scroll', to: 'pagy_infinite_scroll/index.js'\n"
        end

        if File.exist?("app/javascript/application.js")
          append_to_file "app/javascript/application.js" do
            "\nimport 'pagy_infinite_scroll'\n"
          end
        end
      end

      def add_jsbundling_import
        say "For jsbundling, you'll need to manually register the controller", :yellow
        say "See the post-install message above for instructions", :yellow
      end
    end
  end
end
