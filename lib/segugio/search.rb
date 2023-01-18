# frozen_string_literal: true

module Segugio
  # Implements a feature for generic search, that allows to search using ILIKE operator, filter records by exact value
  # and specify result order.
  class Search
    attr_reader :result

    def initialize(relation, options = {})
      @relation = relation
      options = options.to_h.with_indifferent_access
      @configs = options[:configs] || {}
      @options = options

      parse_options

      @result = relation.all

      configure!
      generate_search_result!
    end

    def collection_name
      @collection_name ||= @relation.model_name.collection.split('/').last
    end

    def logger
      @logger ||= Rails.logger
    end

    private

    def parse_options
      parse_string_options

      @configs = (@options[:configs] || {})

      @query = @options[:query].to_s.strip
      @filters = (@options[:filters] || {})
      @exclude = (@options[:exclude] || {})
      @order = @options[:order] || []
    end

    # In this way you can pass variables from client side with `JSON.stringify`
    def parse_string_options
      %i[configs filters order exclude].each do |option|
        @options[option] = JSON.parse(@options[option]) if @options[option].instance_of?(String)
      end
    end

    # Configure search with relation settings
    def configure!
      @columns = @relation.columns.map(&:name)
      @query_fields = @configs[:query_fields] || []
      @filter_fields = @configs[:filter_fields] || []
      @order_fields = (@configs[:order_fields] || []).map(&:to_s)
    end

    # Use search parameters to generate an ActiveRecord Relation which represents
    # the search
    def generate_search_result!
      filter_by_query!
      apply_filters!
      apply_exclude!
      apply_order!
    end

    # Generate the part of the query which filters record by a text search
    def filter_by_query!
      return if @query.blank? || @query_fields.blank?

      # Generate an array with conditions (ex. ['name ILIKE ? OR title ILIKE ?', '%xyz%', '%xyz%'])
      conditions = []
      conditions << @query_fields.map { |field| "#{@relation.table_name}.#{field}::text ILIKE ?" }.join(' OR ')
      @query_fields.each do
        conditions << "%#{@query}%"
      end

      # Use conditions as filter
      @result = @result.where(conditions)
    end

    # Filter records by a set of conditions
    def apply_filters!
      # Iterate over @filter_fields and set filter conditions on result
      @filter_fields.each do |column|
        # TODO: handle filters on array columns
        @result = @result.where(@collection_name => { column => @filters[column] }) if @filters[column]
      end

      # Warn about invalid filter fields
      invalid = @filters.keys.map(&:to_s) - @filter_fields.map(&:to_s)
      logger.warn "Invalid filter fields: #{invalid.inspect}" unless invalid.empty?
    end

    # Exclude from results records by a set of conditions
    def apply_exclude!
      # Iterate over @filter_fields and set exclude conditions on result
      @filter_fields.each do |column|
        @result = @result.where.not(@collection_name => { column => @exclude[column] }) if @exclude[column]
      end

      # Warn about invalid exclude fields
      invalid = @exclude.keys.map(&:to_s) - @filter_fields.map(&:to_s)
      logger.warn "Invalid exclude fields: #{invalid.inspect}" unless invalid.empty?
    end

    # Apply the specified order
    def apply_order!
      return if @order.blank? || @order_fields.blank?

      @result = @result.order(generate_order_fields.join(', '))
    end

    # Generate order fields from search params
    def generate_order_fields
      @order.each_with_object([]) do |item, result|
        case item
        when String, Symbol
          # When order item is a String or a Symbol, just check
          # if it's valid and use that value as order field
          if @order_fields.include?(item.to_s)
            result << "#{@relation.table_name}.#{item}"
          else
            # Report invalid order item
            logger.warn "Invalid order item: #{item.inspect}"
          end
        when Hash
          # When order item is a Hash, we have to build order field from
          # the values specified within item data.
          order_item = item.with_indifferent_access
          if @order_fields.include?(order_item[:field].to_s)
            # If item field is correct, build order field from its data
            result << build_order_field_from_hash(order_item)
          else
            # Report invalid order item
            logger.warn "Invalid order field: #{order_item.inspect} (valid fields are: #{@order_fields.inspect})"
          end
        else
          # Order item has unsupported type
          logger.warn "Invalid order item type: #{item.class} (String, Symbol or Hash expected)"
        end
      end
    end

    # Build order field from a hash like { field: 'name', asc: true|false|nil, nulls_first: true|false|nil }
    def build_order_field_from_hash(data)
      # Use field name as base for order field
      field = "#{@relation.table_name}.#{data[:field]}"

      if data.key?(:asc)
        # When :asc is specified, add "ASC" or "DESC" when its value is "true" or "false" respectively
        field += ' ASC' if Service::Utils.true?(data[:asc])
        field += ' DESC' if Service::Utils.false?(data[:asc])
      end

      if data.key?(:nulls_first)
        # When :nulls_first is specified, add "NULLS FIRST" or "NULLS LAST" when its value
        # is "true" or "false" respectively
        field += ' NULLS FIRST' if Service::Utils.true?(data[:nulls_first])
        field += ' NULLS LAST' if Service::Utils.false?(data[:nulls_first])
      end

      field
    end
  end
end
