# Segugio

Segugio is a Ruby gem that simplifies the implementation of search functionality in Rails using ActiveRecord.
With this gem, you can easily search, filter and sort results in a simple and intuitive way.

It is built on ActiveRecord and provides a clean and easy-to-use interface for creating advanced search queries.
It also provides a variety of utility methods for handling results, allowing you to efficiently sort and filter data.

In addition, Segugio is fully customizable, supporting the creation of custom queries to meet the specific needs of your applications.

In summary, Segugio is an essential tool for anyone looking to implement advanced search functionality in Rails using ActiveRecord,
providing a simple and efficient solution for managing the data of your applications.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add segugio

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install segugio

## Usage

```ruby
# app/models/user.rb

class User < ApplicationRecord
    # Fields to be used for records search by string (text search)
    query_fields: :id, :email, :username, :first_name, :last_name

    # Fields that can be used to filter records by exact value
    filter_fields: :id, :email, :username, :role

    # Fields that can be used to order returned results
    order_fields: :id, :email, :username, :first_name, :last_name, :created_at, :updated_at
    # ... other code ...
end
```

Search for users containing `John Doe` in `query_fields`:

```ruby
User.search(query: 'John Doe')
```

Filter users by role and return results ordered by `email` and `first_name`:

```ruby
User.search(filters: {role: %w[admin moderator]}, order: %i[email first_name])
```

## Custom `search` method name

Sometimes you might want to call `search` method with a different name (e.g. `my_search`), in order to avoid collisions with already existing `search` method. For doing so you can specify a custom search method name for Segugio:

```ruby
# config/initializers/segugio.rb
require 'segugio'

Segugio.search_method_name = :my_search
```

Then to search for users do:

```ruby
User.my_search(query: 'John Doe')
```

## Manually activate Segugio

By default Segugio will wrap `ActiveRecord::Base` in order to automatically add `search`, `query_fields`, `filter_fields` and `order_fields` methods. If you don't wont this behaviour (i.e. already defined a method called `search` in your model), you can load Segugio manually and add its methods only to desired models.

For doing so, you need to add `require: false` to your Gemfile:

```ruby
# Gemfile

gem 'segugio', require: false
```

This will disable autoload of Segugio gem in yout application.

Then, to add Segugio methods to a specific model, you can do:

```ruby
require 'segugio/searchable'

class User < ApplicationRecord
  extend Segugio::Searchable

  query_fields :id, :email, :username, :first_name, :last_name

  # ... other code ...
end
```

Now you'll be able to user `search` method on `User` model:

```ruby
User.search(query: 'john')
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/demetra-it/segugio. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/demetra-it/segugio/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Segugio project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/demetra-it/segugio/blob/master/CODE_OF_CONDUCT.md).
