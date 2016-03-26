$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'lftpsun'
require 'yaml'

Lftpsun.config = YAML.load_file('spec/fixtures/lftpsun.yml')

ENV['LFTPSUN_SECRET'] = "test_secret"

RSpec.configure do |config|
  config.mock_with :mocha
end

Lftpsun::LFTP.class_eval do
  def spawn_command
    raise RuntimeError, "Refusing to run spawn in test"
  end
end
