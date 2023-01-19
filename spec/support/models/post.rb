# frozen_string_literal: true

class Post < ApplicationRecord
  # Define the table structure for the Posts. This will drop the table if already exists and
  # will automatically create the table with the specified columns.
  define_table do |t|
    t.string  :title,     null: false
    t.string  :body,      null: false
    t.string  :status,    null: false
    t.integer :author_id

    t.timestamps
  end

  # Specify the search parameters for the Posts.
  query_fields :id, :title, :body
  filter_fields :id, :author, :status
  order_fields :id, :title, :body, :author, :status, :created_at, :updated_at
end
