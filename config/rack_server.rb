require 'lftpsun/util'
require 'eventmachine'

module RackServer
  extend self

  def run(opts)
    unless Lftpsun.command_exists?('lftp')
      raise "LFTP not found on your system..aborting"
      exit 1
    end

    unless opts[:port]
      raise "Please configure a port to run on"
    end

    EM.run do
      Signal.trap("INT")  { EventMachine.stop }
      Signal.trap("TERM") { EventMachine.stop }

      server  = opts[:server] || 'thin'
      host    = opts[:host]   || '0.0.0.0'
      port    = opts[:port]
      web_app = opts[:app]

      dispatch = Rack::Builder.app do
        map '/' do
          run web_app
        end
      end

      unless ['thin', 'hatetepe', 'goliath'].include? server
        raise "Need an EM webserver, but #{server} isn't"
      end

      Rack::Server.start({
        app:    dispatch,
        server: server,
        signals: false,
        Host:   host,
        Port:   port
      })
    end
  end
end
