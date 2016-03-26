require 'sinatra/base'
require 'thin'
require 'eventmachine'

require 'lftpsun/supervisor'

module Lftpsun
  module Api
    class ClientApp < Sinatra::Base
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

        puts "Processing request:\n#{data}" if DEBUG
        response = "Processing notification for "
        VALID_CLIENT_PARAMS.each do |key|
          response += "\n#{key}: #{data[key]}"
        end
        puts response
        supervisor.push(data)
      end
    end
  end
end
