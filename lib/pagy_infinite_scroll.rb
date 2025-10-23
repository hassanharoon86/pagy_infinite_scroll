# frozen_string_literal: true

require_relative "pagy_infinite_scroll/version"
require_relative "pagy_infinite_scroll/configuration"
require_relative "pagy_infinite_scroll/controller_helper"
require_relative "pagy_infinite_scroll/view_helper"
require_relative "pagy_infinite_scroll/engine" if defined?(Rails)

module PagyInfiniteScroll
  class Error < StandardError; end

  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end

    def config
      self.configuration ||= Configuration.new
    end
  end
end
