# frozen_string_literal: true

module PagyInfiniteScroll
  class Configuration
    attr_accessor :items_per_page,
                  :scroll_threshold,
                  :loading_indicator,
                  :auto_initialize,
                  :preserve_state,
                  :debounce_delay

    def initialize
      @items_per_page = 50
      @scroll_threshold = 100 # pixels from bottom
      @loading_indicator = true
      @auto_initialize = true
      @preserve_state = true
      @debounce_delay = 500 # milliseconds
    end
  end
end
