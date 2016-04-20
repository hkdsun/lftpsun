require 'sinatra'

module Lftpsun
  module Api
    class Base < Sinatra::Base
      def authorized?(secret)
        secret == APP_SECRET
      end

      def verify_params(params, *allowed)
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
    end
  end
end
