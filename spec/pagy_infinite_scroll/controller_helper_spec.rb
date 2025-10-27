# frozen_string_literal: true

require 'pagy'
require 'active_support/all'
require 'ostruct'

RSpec.describe PagyInfiniteScroll::ControllerHelper do
  let(:controller_class) do
    Class.new do
      include PagyInfiniteScroll::ControllerHelper

      attr_accessor :params

      def initialize
        @params = {}
      end
    end
  end

  let(:controller) { controller_class.new }

  before do
    # Set up default configuration
    PagyInfiniteScroll.configure do |config|
      config.items_per_page = 25
    end
  end

  describe "#pagy_infinite_scroll" do
    # Create a mock collection that behaves like ActiveRecord
    let(:collection) do
      items = (1..100).to_a
      collection = double("Collection")
      allow(collection).to receive(:offset) { |n| collection }
      allow(collection).to receive(:limit) { |n| items.first(n) }
      allow(collection).to receive(:count).with(any_args).and_return(100)
      collection
    end

    context "with default options" do
      it "returns pagy object and paginated records" do
        pagy, records = controller.pagy_infinite_scroll(collection)

        expect(pagy).to be_a(Pagy)
        expect(records).to be_an(Array)
      end

      it "uses configured items_per_page as default" do
        pagy, _records = controller.pagy_infinite_scroll(collection)

        expect(pagy.limit).to eq(25)
      end
    end

    context "with custom limit" do
      it "respects custom limit option" do
        pagy, _records = controller.pagy_infinite_scroll(collection, limit: 10)

        expect(pagy.limit).to eq(10)
      end
    end
  end

  describe "#pagy_infinite_scroll_json" do
    let(:pagy) do
      Pagy.new(count: 100, page: 1, limit: 10)
    end

    let(:records) do
      [
        OpenStruct.new(id: 1, title: "Item 1"),
        OpenStruct.new(id: 2, title: "Item 2")
      ]
    end

    context "without serializer block" do
      it "returns records as-is" do
        result = controller.pagy_infinite_scroll_json(pagy, records)

        expect(result[:records]).to eq(records)
      end

      it "includes pagy metadata" do
        result = controller.pagy_infinite_scroll_json(pagy, records)

        expect(result[:pagy]).to include(
          page: 1,
          pages: 10,
          count: 100,
          next: 2,
          prev: nil,
          from: 1,
          to: 10
        )
      end
    end

    context "with serializer block" do
      it "serializes records using the block" do
        result = controller.pagy_infinite_scroll_json(pagy, records) do |record|
          { id: record.id, name: record.title }
        end

        expect(result[:records]).to eq([
          { id: 1, name: "Item 1" },
          { id: 2, name: "Item 2" }
        ])
      end
    end

    context "pagination metadata" do
      it "includes all required pagy fields" do
        result = controller.pagy_infinite_scroll_json(pagy, records)

        expect(result[:pagy].keys).to contain_exactly(
          :page, :pages, :count, :next, :prev, :from, :to
        )
      end

      context "on last page" do
        let(:pagy) { Pagy.new(count: 25, page: 3, limit: 10) }

        it "has next as nil" do
          result = controller.pagy_infinite_scroll_json(pagy, records)

          expect(result[:pagy][:next]).to be_nil
        end
      end

      context "on middle page" do
        let(:pagy) { Pagy.new(count: 100, page: 5, limit: 10) }

        it "has both prev and next" do
          result = controller.pagy_infinite_scroll_json(pagy, records)

          expect(result[:pagy][:prev]).to eq(4)
          expect(result[:pagy][:next]).to eq(6)
        end
      end
    end
  end
end
