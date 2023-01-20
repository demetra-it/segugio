# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
ENV['RAKE_ENV'] = 'test'

current_path = File.expand_path('.', __dir__)

db_config_file = "#{current_path}/database.yml"
unless File.exist?(db_config_file)
  puts <<~DOC
    Please create #{current_path}/database.yml with the following content:

    test:
      adapter: postgresql # change if necessary
      encoding: unicode
      database: segugio_test
      host: localhost
      port: 5342
      user: #{`whoami`.strip}

    NOTE: remember to create the database "segugio_test" before running the tests.

    e.g. with PostgreSQL run `createdb segugio_test`
  DOC

  abort 'Missing database.yml file'
end

db_config = YAML.load_file(db_config_file)

if ActiveRecord.version < Gem::Version.new('4.2.6')
  # ActiveRecord < 4.2.5 doesn't support PostgreSQL >= 12 because of
  # removal of `client_min_messages: panic` parameter.
  # We're going to monkey patch PostgreSQLAdapter in order
  # to set `client_min_messages: warning` instead.
  require 'active_record/connection_adapters/postgresql_adapter'

  class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
    def set_standard_conforming_strings
      old, self.client_min_messages = client_min_messages, 'warning'
      execute('SET standard_conforming_strings = on', 'SCHEMA') rescue nil
    ensure
      self.client_min_messages = old
    end
  end
end

if ActiveRecord.version < Gem::Version.new('6.0')
  module Rails
    def self.env
      ENV.fetch('RAILS_ENV', nil)
    end
  end

  ActiveRecord::Base.configurations = db_config
else
  ActiveRecord::Base.configurations = ActiveRecord::DatabaseConfigurations.new(db_config)
end

log_dir = File.join(File.expand_path('../../..', __dir__), 'log')
FileUtils.mkdir_p(log_dir)

ActiveRecord::Base.logger = Logger.new("#{log_dir}/test.log")

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.establish_connection
end
