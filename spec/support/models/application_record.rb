# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.define_table(&block)
    connection = ActiveRecord::Base.connection

    connection.drop_table table_name, if_exists: true

    connection.create_table table_name, &block
  end
end
