# frozen_string_literal: true

module ActiveRecord
  # Wraps ActiveRecord::Base to add `search` method and `query_fields`,
  # `filter_fields` and `order_fields` helper class methods.
  class Base
    class << self
      # Defines the fields that will be used to perform the search.
      def query_fields(*args)
        @query_fields = args.flatten unless args.blank?
        @query_fields || []
      end

      # Defines the fields that can be used for filters.
      def filter_fields(*args)
        @filter_fields = args.flatten unless args.blank?
        @filter_fields || []
      end

      # Defines the fields that can be used for ordering.
      def order_fields(*args)
        @order_fields = args.flatten unless args.blank?
        @order_fields || columns.map(&:name)
      end

      # Implements the `search` method for the model.
      def search(query: '', filters: {}, exclude: {}, order: [], configs: {})
        Segugio::Search.new(
          self,
          query: query,
          filters: filters,
          exclude: exclude,
          order: order,
          configs: {
            query_fields: configs[:query_fields] || query_fields,
            filter_fields: configs[:filter_fields] || filter_fields,
            order_fields: configs[:order_fields] || order_fields
          }
        ).result
      end
    end
  end
end
