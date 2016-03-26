ENV['LFTPSUN_SECRET'] = "test_secret"

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'lftpsun'
require 'yaml'

Lftpsun.config = YAML.load_file('spec/fixtures/lftpsun.yml')


RSpec.configure do |config|
  config.mock_with :mocha
end

Lftpsun::LFTP.class_eval do
  def spawn_command
    raise RuntimeError, "Refusing to run spawn in test"
  end
end

def with_config(config)
  old_config = Lftpsun.config.dup
  Lftpsun.config = config
  yield
ensure
  Lftpsun.config = old_config
end
