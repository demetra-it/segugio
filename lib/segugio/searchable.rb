# frozen_string_literal: true

require_relative 'search'

module Segugio
  class << self
    # Define an accessor where to store current search method name.
    attr_accessor :__search_method_name

    # Returns current search method name of Segugio.
    def search_method_name
      __sarch_method_name
    end

    # Updates current search method name of Segugio.
    # This method will remove the old search method and define a new one with
    # the given name. e.g.: `Segugio.search_method_name = :my_search` will define
    # a new `my_search` method on all models that extend `Segugio::Searchable`.
    def search_method_name=(name)
      return if name.to_s.strip == '' || name.to_s.strip == __search_method_name

      current_method_name = __search_method_name || 'search'

      Segugio::Searchable.remove_method(current_method_name) if Segugio::Searchable.method_defined?(current_method_name)
      self.__search_method_name = name

      Segugio::Searchable.define_method(name) do |query: '', filters: {}, exclude: {}, order: [], configs: {}|
        segugio_perform_search(query: query, filters: filters, exclude: exclude, order: order, configs: configs)
      end
    end
  end

  module Searchable
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

    protected

    # Implements the `search` method for the model.
    def segugio_perform_search(query: '', filters: {}, exclude: {}, order: [], configs: {})
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

Segugio.search_method_name = :search
