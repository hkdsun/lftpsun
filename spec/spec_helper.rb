$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'lftpsun'

Lftpsun.config = YAML.load_file('fixtures/lftpsun.yml')

RSpec.configure do |config|
  config.mock_with :mocha
end
