# frozen_string_literal: true

module ActiveRecord
  # Wraps ActiveRecord::Base to add `search` method and `query_fields`,
  # `filter_fields` and `order_fields` helper class methods.
  class Base
    extend Segugio::Searchable
  end
end
