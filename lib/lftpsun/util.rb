require 'json'

module Lftpsun
  def authorized?(secret)
    secret == APP_SECRET
  end

  def verify_params(params, allowed = [])
    allowed.each do |key|
      return false unless (params[key] || params[key.to_s])
    end
    true
  end

  def parse_json(request)
    request.body.rewind
    parsed_response = JSON.parse(request.body.read)
  rescue JSON::ParserError => e
    {}
  end

  def command_exists?(command)
    ENV['PATH'].split(File::PATH_SEPARATOR).any? { |d| File.exists? File.join(d, command) }
  end

  def download_dir
    config['client']['download_dir']
  end

  def debug?
    config['debug_mode'] == 'true'
  end
end
