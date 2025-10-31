# Pagy Infinite Scroll Configuration
#
# Configure the default settings for infinite scroll pagination

PagyInfiniteScroll.configure do |config|
  # Number of items to load per page
  # Default: 50
  config.items_per_page = 50

  # Distance from bottom of container in pixels to trigger loading more items
  # Default: 100
  config.scroll_threshold = 100

  # Show loading indicator while fetching new items
  # Default: true
  config.loading_indicator = true

  # Preserve form state and URL parameters during infinite scroll
  # Default: true
  config.preserve_state = true

  # Debounce delay for search in milliseconds
  # Default: 500
  config.debounce_delay = 500

  # Default rendering mode for infinite scroll
  # Options: 'json' (client-side rendering) or 'js' (server-side rendering with .js.erb)
  # Default: 'json'
  #
  # 'json' mode: Requires custom Stimulus controller with createItemHTML() method
  # 'js' mode: Uses server-rendered HTML via .js.erb templates (simpler, recommended for most apps)
  config.render_mode = 'json'
end
