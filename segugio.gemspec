# frozen_string_literal: true

require_relative 'lib/segugio/version'

Gem::Specification.new do |spec|
  spec.name = 'segugio'
  spec.version = Segugio::VERSION
  spec.authors = ['Groza Sergiu']
  spec.email = ['groza@opinioni.net']

  spec.summary = 'A Ruby gem for fast and easy implementation of search functionality in Rails with ActiveRecord.'
  spec.description = <<~DESC
    Segugio is a Ruby gem that simplifies the implementation of search functionality in Rails using ActiveRecord.
    With this gem, you can easily search, filter and sort results in a simple and intuitive way.

    It is built on ActiveRecord and provides a clean and easy-to-use interface for creating advanced search queries.
    It also provides a variety of utility methods for handling results, allowing you to efficiently sort and filter data.

    In addition, Segugio is fully customizable, supporting the creation of custom queries to meet the specific needs of your applications.

    In summary, Segugio is an essential tool for anyone looking to implement advanced search functionality in Rails using ActiveRecord,
    providing a simple and efficient solution for managing the data of your applications.
  DESC
  spec.homepage = 'https://github.com/demetra-it/segugio'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_dependency 'activerecord', '~> 7', '>= 4.0'

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
