require "lftpsun/version"

Dir[File.dirname(__FILE__) + '/lftpsun/*.rb'].each {|file| require file }

Lftpsun::NoConfigFound = Class.new(StandardError)

module Lftpsun
  extend self

  APP_SECRET = ENV['LFTPSUN_SECRET']
  VALID_CLIENT_PARAMS = ['label', 'path', 'name'].freeze

  def config
    raise NoConfigFound, "Please set the configuration hash using Lftpsun#config=" unless @config
    @config
  end

  def config=(config)
    @config = config
  end
end
