require 'thin'
require 'eventmachine'
require 'lftpsun/api/base'


module Lftpsun
  module Api
    class ClientApp < Base
      unless APP_SECRET
        raise "No secret configured..aborting"
        exit 1
      end

      configure do
        set :threaded, false
      end

      supervisor = Supervisor.new

      before do
        payload = parse_json(request)
        halt 403 unless authorized?(payload['secret'])
        request.body.rewind
      end

      post '/notify' do
        data = parse_json(request)

        puts "Processing request:\n#{data}" if Lftpsun.debug?
        response = "Processing notification for "
        ['label', 'path', 'name'].each do |key|
          response += "\n#{key}: #{data[key]}"
        end

        event = SyncEvent.new(data['name'], data['path'], data['label'], data['host'])
        supervisor.push(event)
      end
    end
  end
end
