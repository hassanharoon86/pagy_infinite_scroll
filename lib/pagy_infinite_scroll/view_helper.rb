# frozen_string_literal: true

module PagyInfiniteScroll
  module ViewHelper
    # Renders an infinite scroll container
    #
    # @param pagy [Pagy] The pagy object
    # @param url [String] The URL to fetch more items
    # @param options [Hash] HTML and Stimulus options
    # @option options [String] :container_class CSS classes for the container
    # @option options [String] :max_height Maximum height (e.g., "600px")
    # @option options [Hash] :data Additional data attributes
    # @yield The content to render inside the container
    #
    # @example
    #   <%= infinite_scroll_container(@pagy, products_path(format: :json)) do %>
    #     <div data-infinite-scroll-target="itemsContainer">
    #       <%= render @products %>
    #     </div>
    #   <% end %>
    #
    def infinite_scroll_container(pagy, url, options = {}, &block)
      container_class = options[:container_class] || ''
      max_height = options[:max_height] || '600px'
      data_attrs = options[:data] || {}

      content_tag :div,
                  class: container_class,
                  style: "max-height: #{max_height}; overflow-y: auto;",
                  data: {
                    controller: 'pagy-infinite-scroll',
                    pagy_infinite_scroll_url_value: url,
                    pagy_infinite_scroll_page_value: pagy.page,
                    pagy_infinite_scroll_loading_value: false,
                    pagy_infinite_scroll_has_more_value: pagy.next.present?,
                    **stimulus_data_attributes(data_attrs)
                  } do
        block.call
      end
    end

    # Renders the loading indicator
    #
    # @param options [Hash] Options for the loading indicator
    # @option options [String] :text Loading text
    # @option options [String] :class CSS classes
    #
    # @example
    #   <%= infinite_scroll_loading_indicator %>
    #
    # @example Custom text
    #   <%= infinite_scroll_loading_indicator(text: "Loading products...") %>
    #
    def infinite_scroll_loading_indicator(options = {})
      text = options[:text] || 'Loading more items...'
      css_class = options[:class] || 'hidden p-4 text-center'

      content_tag :div,
                  class: css_class,
                  data: { pagy_infinite_scroll_target: 'loadingIndicator' } do
        content_tag :div, class: 'inline-flex items-center gap-2 text-gray-600' do
          concat(spinner_svg)
          concat(content_tag(:span, text))
        end
      end
    end

    # Renders a scroll target container for items
    #
    # @param options [Hash] HTML options
    # @option options [String] :class CSS classes
    # @option options [String] :tag HTML tag (default: 'div')
    # @yield The content to render inside the container
    #
    # @example
    #   <%= infinite_scroll_items_container do %>
    #     <%= render @products %>
    #   <% end %>
    #
    # @example With table rows
    #   <%= infinite_scroll_items_container(tag: 'tbody') do %>
    #     <%= render @items %>
    #   <% end %>
    #
    def infinite_scroll_items_container(options = {}, &block)
      tag = options.delete(:tag) || 'div'
      css_class = options.delete(:class) || ''

      content_tag tag,
                  class: css_class,
                  data: { pagy_infinite_scroll_target: 'itemsContainer' } do
        block.call
      end
    end

    private

    def spinner_svg
      content_tag :svg,
                  class: 'animate-spin h-5 w-5',
                  xmlns: 'http://www.w3.org/2000/svg',
                  fill: 'none',
                  viewBox: '0 0 24 24' do
        concat(tag(:circle, class: 'opacity-25', cx: '12', cy: '12', r: '10', stroke: 'currentColor', 'stroke-width': '4'))
        concat(tag(:path, class: 'opacity-75', fill: 'currentColor', d: 'M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z'))
      end
    end

    def stimulus_data_attributes(attrs)
      attrs.transform_keys { |key| "pagy_infinite_scroll_#{key}_value".to_sym }
    end
  end
end
