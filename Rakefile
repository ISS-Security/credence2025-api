# frozen_string_literal: true

require 'rake/testtask'
require './require_app'

task :default => :spec

desc 'Tests API specs only'
task :api_spec do
  sh 'ruby spec/api_spec.rb'
end

desc 'Test all the specs'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
  t.warning = false
end

desc 'Runs rubocop on tested code'
task :style => [:spec, :audit] do
  sh 'rubocop .'
end

desc 'Update vulnerabilities lit and audit gems'
task :audit do
  sh 'bundle audit check --update'
end

desc 'Checks for release'
task :release_check => [:spec, :style, :audit] do
  puts "\nReady for release!"
end

task :print_env do # rubocop:disable Rake/Desc
  puts "Environment: #{ENV['RACK_ENV'] || 'development'}"
end

desc 'Run application console (pry)'
task :console => :print_env do
  sh 'pry -r ./spec/test_load_all'
end

namespace :db do
  task :load do # rubocop:disable Rake/Desc
    require_app(nil) # load nothing by default
    require 'sequel'

    Sequel.extension :migration
    @app = Credence::Api
  end

  task :load_models do # rubocop:disable Rake/Desc
    require_app('models')
  end

  desc 'Run migrations'
  task :migrate => [:load, :print_env] do
    puts 'Migrating database to latest'
    Sequel::Migrator.run(@app.DB, 'db/migrations')
  end

  desc 'Destroy data in database; maintain tables'
  task :delete => :load_models do
    Credence::Project.dataset.destroy
  end

  desc 'Delete dev or test database file'
  task :drop => :load do
    if @app.environment == :production
      puts 'Cannot wipe production database!'
      return
    end

    db_filename = "db/local/#{Credence::Api.environment}.db"
    FileUtils.rm(db_filename)
    puts "Deleted #{db_filename}"
  end
end
