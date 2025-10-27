# frozen_string_literal: true

require 'active_support/concern'

module PagyInfiniteScroll
  module ControllerHelper
    extend ActiveSupport::Concern

    included do
      begin
        require 'pagy'
        include Pagy::Backend
      rescue LoadError
        raise LoadError, "Pagy gem is required. Add 'gem \"pagy\"' to your Gemfile and run 'bundle install'"
      rescue NameError
        raise NameError, "Pagy::Backend not found. Make sure Pagy is properly installed."
      end
    end

    # Pagy with infinite scroll support
    #
    # @param collection [ActiveRecord::Relation] The collection to paginate
    # @param options [Hash] Options for pagy and infinite scroll
    # @return [Array<Pagy, Array>] The pagy object and paginated collection
    #
    # @example
    #   @pagy, @products = pagy_infinite_scroll(Product.all)
    #
    # @example With custom options
    #   @pagy, @products = pagy_infinite_scroll(Product.all, limit: 25)
    #
    def pagy_infinite_scroll(collection, **options)
      options[:limit] ||= PagyInfiniteScroll.config.items_per_page
      pagy, records = pagy(collection, **options)

      [pagy, records]
    end

    # Respond with infinite scroll format
    #
    # @param pagy [Pagy] The pagy object
    # @param records [Array] The paginated records
    # @param serializer [Proc, nil] Optional custom serializer for records
    # @yield [record] Block to serialize each record
    # @return [Hash] JSON response with records and pagination data
    #
    # @example Basic usage
    #   respond_to do |format|
    #     format.html
    #     format.json do
    #       render json: pagy_infinite_scroll_json(@pagy, @products) { |product|
    #         {
    #           id: product.id,
    #           title: product.title,
    #           price: product.price
    #         }
    #       }
    #     end
    #   end
    #
    def pagy_infinite_scroll_json(pagy, records, &serializer)
      {
        records: serialize_records(records, &serializer),
        pagy: {
          page: pagy.page,
          pages: pagy.pages,
          count: pagy.count,
          next: pagy.next,
          prev: pagy.prev,
          from: pagy.from,
          to: pagy.to
        }
      }
    end

    private

    def serialize_records(records, &serializer)
      return records unless block_given?

      records.map { |record| serializer.call(record) }
    end
  end
end
