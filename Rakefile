# frozen_string_literal: true

require_relative 'config/application'
require 'yaml'
require 'sequel'
task :bundle do
  sh 'bundle install --path .bundle'
end


def db_uri
  URI(Application.settings[:database_url])
end

def db_name
  db_uri.path[1..-1]
end

def sys_db_args
  db_port = db_uri.port
  db_host = db_uri.host
  db_user = db_uri.user
  "-p #{db_port} -h #{db_host} -U #{db_user}"
end

namespace :db do
  desc 'Run database migrations'
  # rake db:migrate[002]
  task :migrate, [:version] do |_t, args|
    Sequel.extension :migration
    puts "Sequel connect to #{Application.settings[:database_url]}"
    db = Sequel.connect(Application.settings[:database_url])
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(db, 'db/migrations', target: args[:version].to_i)
    else
      puts 'Migrating to latest'
      Sequel::Migrator.run(db, 'db/migrations')
    end
  end

  task :set_pg_password do
    ENV['PGPASSWORD'] = db_uri.password
  end

  desc 'Create test and dev databases'
  task create: [:set_pg_password] do
    sh "createdb #{sys_db_args} #{db_name}"
    Rake::Task['db:migrate'].invoke
  end

  desc 'Drop test and dev databases'
  task drop: [:set_pg_password] do
    sh "dropdb #{sys_db_args} #{db_name} || true" # drop if exists
  end

  desc 'Create a copy of the database'
  task :dump, [:filename] => [:set_pg_password] do |_t, args|
    filename = args[:filename] || 'latest.dump'
    sh "pg_dump -Fc --no-acl --no-owner #{sys_db_args} #{db_name} > #{filename}"
  end
end

task :redis_local do
  db_path = File.expand_path(File.join(Dir.pwd, 'tmp/db_redis_test'))
  FileUtils.mkdir_p(db_path) unless File.directory?(db_path)
  sh %(sh -c 'echo "port 21002\n
      bind 127.0.0.1\n
      daemonize no\n
      logfile stdout\n
      dir \"#{db_path}\"" | redis-server -' 2>&1)
end

task :console do
  puts "Loading #{Application.env} environment (Application #{Application::VERSION})"
  exec 'bundle exec ruby -r pry -r irb -r irb/completion  -e "include Application; binding.pry" -r./config/environment.rb'
end

task :test do
  exec 'bundle exec rspec spec'
end
