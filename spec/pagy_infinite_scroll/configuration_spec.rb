# frozen_string_literal: true

RSpec.describe PagyInfiniteScroll::Configuration do
  subject(:config) { described_class.new }

  describe "default values" do
    it "has default items_per_page of 50" do
      expect(config.items_per_page).to eq(50)
    end

    it "has default scroll_threshold of 100" do
      expect(config.scroll_threshold).to eq(100)
    end

    it "has loading_indicator enabled by default" do
      expect(config.loading_indicator).to be true
    end

    it "has auto_initialize enabled by default" do
      expect(config.auto_initialize).to be true
    end

    it "has preserve_state enabled by default" do
      expect(config.preserve_state).to be true
    end

    it "has default debounce_delay of 500" do
      expect(config.debounce_delay).to eq(500)
    end
  end

  describe "setters" do
    it "allows changing items_per_page" do
      config.items_per_page = 25
      expect(config.items_per_page).to eq(25)
    end

    it "allows changing scroll_threshold" do
      config.scroll_threshold = 200
      expect(config.scroll_threshold).to eq(200)
    end

    it "allows changing loading_indicator" do
      config.loading_indicator = false
      expect(config.loading_indicator).to be false
    end

    it "allows changing auto_initialize" do
      config.auto_initialize = false
      expect(config.auto_initialize).to be false
    end

    it "allows changing preserve_state" do
      config.preserve_state = false
      expect(config.preserve_state).to be false
    end

    it "allows changing debounce_delay" do
      config.debounce_delay = 1000
      expect(config.debounce_delay).to eq(1000)
    end
  end
end
