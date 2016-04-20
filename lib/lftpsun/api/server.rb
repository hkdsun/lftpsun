require 'lftpsun/api/base'

module Lftpsun
  module Api
    class ServerApp < Base
      unless APP_SECRET
        raise "No secret configured (LFTPSUN_SECRET)..aborting"
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
        msg = "Wrong arguments include name, url, port"
        halt 400, msg unless verify_params(params, :name, :url, :port)

        name = params['name']
        callback_url = params['url']
        callback_port = params['port']

        SUBSCRIBED_CLIENTS << Lftpsun::Client.new(name, callback_url, callback_port)
        "Subscription successfull for client #{name}"
      end

      post '/publish' do
        params = parse_json(request)
        halt 400, "Wrong arguments. Include #{['label', 'path', 'name'].join(', ')}" unless verify_params(params, 'label', 'path', 'name')

        data = { label: params['label'], path: params['path'], name: params['name'], host: Lftpsun.config['server']['hostname'] }
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
