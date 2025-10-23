# frozen_string_literal: true

require "rails"

module PagyInfiniteScroll
  class Engine < ::Rails::Engine
    # Don't isolate namespace to allow helpers to load into main app
    engine_name 'pagy_infinite_scroll'

    # Ensure lib files are loaded
    config.eager_load_paths << File.expand_path("../../", __FILE__)

    # Load assets if asset pipeline is available
    initializer "pagy_infinite_scroll.assets", before: :load_config_initializers do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/assets/javascripts")
        app.config.assets.precompile += %w[
          pagy_infinite_scroll/infinite_scroll_controller.js
          pagy_infinite_scroll/index.js
          pagy_infinite_scroll_controller.js
        ]
      end
    end

    # Support for importmap-rails
    initializer "pagy_infinite_scroll.importmap", before: "importmap" do |app|
      if defined?(Importmap)
        # Make the standalone controller available to importmap
        app.config.assets.paths << root.join("app/assets/javascripts") unless app.config.assets.paths.include?(root.join("app/assets/javascripts"))
      end
    end

    # Load helpers into ActionController and ActionView
    initializer "pagy_infinite_scroll.helpers" do
      ActiveSupport.on_load(:action_controller_base) do
        helper PagyInfiniteScroll::ViewHelper if defined?(PagyInfiniteScroll::ViewHelper)
        include PagyInfiniteScroll::ControllerHelper if defined?(PagyInfiniteScroll::ControllerHelper)
      end

      ActiveSupport.on_load(:action_view) do
        include PagyInfiniteScroll::ViewHelper if defined?(PagyInfiniteScroll::ViewHelper)
      end
    end

    # Fallback for direct inclusion
    config.after_initialize do
      if defined?(ActionController::Base)
        ActionController::Base.include(PagyInfiniteScroll::ControllerHelper) unless ActionController::Base.include?(PagyInfiniteScroll::ControllerHelper)
        ActionController::Base.helper(PagyInfiniteScroll::ViewHelper) if defined?(PagyInfiniteScroll::ViewHelper)
      end
    end
  end
end
