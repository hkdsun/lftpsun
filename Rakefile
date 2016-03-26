require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'yaml'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :environment do
  require "lftpsun"
  Lftpsun.config = YAML.load_file('config/lftpsun.yml')
  require_relative "config/rack_server"
end

task :server => :environment do
  require "lftpsun/api/server"
  RackServer.run(app: Lftpsun::Api::ServerApp.new, port: 4793)
end

task :client => :environment do
  require "lftpsun/api/client"
  RackServer.run(app: Lftpsun::Api::ClientApp.new, port: 4794)
end
