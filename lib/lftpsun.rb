require "lftpsun/version"
require 'json'

Dir[File.dirname(__FILE__) + '/lftpsun/*.rb'].each {|file| require file }

Lftpsun::NoConfigFound = Class.new(StandardError)

module Lftpsun
  extend self

  APP_SECRET = ENV['LFTPSUN_SECRET']

  def command_exists?(command)
    ENV['PATH'].split(File::PATH_SEPARATOR).any? { |d| File.exists? File.join(d, command) }
  end

  def download_dir
    config['client']['download_dir']
  end

  def debug?
    config['debug_mode']
  end

  def config
    raise NoConfigFound, "Please set the configuration hash using Lftpsun#config=" unless @config
    @config
  end

  def config=(config)
    @config = config
    if validations = verify_config
      puts validations.join("\n")
      puts "Configuration is incorrect due to above reasons...aborting"
      exit 1
    end
  end

  def verify_config
    valid = []
    valid << "Download directory #{download_dir} does not exist" unless File.exist?(download_dir)
    return nil if valid.empty?
    valid
  end
end
