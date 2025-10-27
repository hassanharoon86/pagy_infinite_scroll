# frozen_string_literal: true

require 'pagy'
require 'active_support/all'
require 'action_view'

RSpec.describe PagyInfiniteScroll::ViewHelper do
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::OutputSafetyHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Context
  include described_class

  let(:pagy_first_page) { Pagy.new(count: 100, page: 1, limit: 25) }
  let(:pagy_middle_page) { Pagy.new(count: 100, page: 2, limit: 25) }
  let(:pagy_last_page) { Pagy.new(count: 100, page: 4, limit: 25) }

  describe "#infinite_scroll_container" do
    it "creates a div with correct data attributes" do
      html = infinite_scroll_container(pagy_first_page, "/products.json") { "Content" }

      expect(html).to include('data-controller="pagy-infinite-scroll"')
      expect(html).to include('data-pagy-infinite-scroll-url-value="/products.json"')
      expect(html).to include('data-pagy-infinite-scroll-page-value="1"')
    end

    it "sets has_more to true when there are more pages" do
      html = infinite_scroll_container(pagy_first_page, "/products.json") { "Content" }

      expect(html).to include('data-pagy-infinite-scroll-has-more-value="true"')
    end

    it "sets has_more to false on last page" do
      html = infinite_scroll_container(pagy_last_page, "/products.json") { "Content" }

      expect(html).to include('data-pagy-infinite-scroll-has-more-value="false"')
    end

    it "includes custom container class" do
      html = infinite_scroll_container(pagy_first_page, "/products.json", container_class: "custom-class") { "Content" }

      expect(html).to include('class="custom-class"')
    end

    it "includes custom max height" do
      html = infinite_scroll_container(pagy_first_page, "/products.json", max_height: "800px") { "Content" }

      expect(html).to include('max-height: 800px')
    end

    it "renders the block content" do
      html = infinite_scroll_container(pagy_first_page, "/products.json") { "Test Content" }

      expect(html).to include("Test Content")
    end

    it "includes additional data attributes" do
      html = infinite_scroll_container(pagy_first_page, "/products.json", data: { custom: "value" }) { "Content" }

      expect(html).to include('data-pagy-infinite-scroll-custom-value="value"')
    end
  end

  describe "#infinite_scroll_loading_indicator" do
    it "creates a loading indicator with default text" do
      html = infinite_scroll_loading_indicator

      expect(html).to include('data-pagy-infinite-scroll-target="loadingIndicator"')
      expect(html).to include("Loading more items...")
    end

    it "includes hidden class by default" do
      html = infinite_scroll_loading_indicator

      expect(html).to include("hidden")
    end

    it "allows custom text" do
      html = infinite_scroll_loading_indicator(text: "Loading products...")

      expect(html).to include("Loading products...")
    end

    it "allows custom CSS classes" do
      html = infinite_scroll_loading_indicator(class: "custom-loading-class")

      expect(html).to include('class="custom-loading-class"')
    end

    it "includes a spinner SVG" do
      html = infinite_scroll_loading_indicator

      expect(html).to include("<svg")
      expect(html).to include("animate-spin")
    end
  end

  describe "#infinite_scroll_items_container" do
    it "creates a div with items container target" do
      html = infinite_scroll_items_container { "Items" }

      expect(html).to include('data-pagy-infinite-scroll-target="itemsContainer"')
      expect(html).to include("Items")
    end

    it "allows custom CSS classes" do
      html = infinite_scroll_items_container(class: "items-grid") { "Items" }

      expect(html).to include('class="items-grid"')
    end

    it "allows custom HTML tag" do
      html = infinite_scroll_items_container(tag: "tbody") { "<tr><td>Row</td></tr>".html_safe }

      expect(html).to start_with("<tbody")
      expect(html).to include("<tr><td>Row</td></tr>")
    end

    it "renders the block content" do
      html = infinite_scroll_items_container { "<div>Item 1</div><div>Item 2</div>".html_safe }

      expect(html).to include("<div>Item 1</div>")
      expect(html).to include("<div>Item 2</div>")
    end
  end
end
