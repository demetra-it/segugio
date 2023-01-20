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

ActiveRecord::Base.configurations = ActiveRecord.version < Gem::Version.new('6.0') ? db_config : ActiveRecord::DatabaseConfigurations.new(db_config)

log_dir = File.join(File.expand_path('../../..', __dir__), 'log')
FileUtils.mkdir_p(log_dir)

ActiveRecord::Base.logger = Logger.new("#{log_dir}/test.log")

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.establish_connection
end
