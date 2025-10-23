# frozen_string_literal: true

require "rails"
require "pagy"

module PagyInfiniteScroll
  class Engine < ::Rails::Engine
    isolate_namespace PagyInfiniteScroll

    config.eager_load_paths << File.expand_path("lib", __dir__)

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
end
