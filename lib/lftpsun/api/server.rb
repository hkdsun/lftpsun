require 'sinatra'
require 'yaml'

require 'lftpsun/client'

module Lftpsun
  module Api
    class ServerApp < Sinatra::Base
      unless APP_SECRET
        raise "No secret configured..aborting"
        exit 1
      end

      SUBSCRIBED_CLIENTS = Lftpsun.config['default_clients'].map(&Lftpsun::Client.method(:deserialize))

      before do
        payload = parse_json(request)
        halt 403 unless authorized?(payload['secret'])
        request.body.rewind
      end

      get '/' do
        "Nothing to see here"
      end

      post '/subscribe' do
        params = parse_json(request)
        halt 400, "Wrong arguments include name, callback_url, callback_port" unless verify_params(params, :name, :callback_url, :callback_port)

        name = params['name']
        callback_url = params['callback_url']
        callback_port = params['callback_port']

        SUBSCRIBED_CLIENTS << Lftpsun::Client.new(name, callback_url, callback_port)
        "Subscription successfull for client #{name}"
      end

      post '/publish' do
        params = parse_json(request)
        halt 400, "Wrong arguments. Include #{VALID_CLIENT_PARAMS.join(', ')}" unless verify_params(params, *VALID_CLIENT_PARAMS)

        label = params['label']
        path = params['path']

        response = "Sending messages to clients:\n"
        SUBSCRIBED_CLIENTS.each do |client|
          if client.send_notification(data)
            response += "[SUCCESS] client #{client.name}\n"
          else
            response += "[FAILURE] client #{client.name}\n"
          end
        end
        response
      end
    end
  end
end
