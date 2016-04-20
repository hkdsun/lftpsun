require 'eventmachine'

module Lftpsun
  class Supervisor
    def initialize
      @queue = []
    end

    def push(event)
      @queue.push(event)
      EM.defer do
        with_fallback do
          process(event)
        end
      end
    end

    private

    def process(event)
      event.start
      lftp = LFTP.new(source: event.src_path, destination: event.dest_path, host: event.host)
      lftp.run
    ensure
      event.finish
      puts "Popping #{event} off the queue"
      @queue.delete(event)
    end

    def with_fallback
      begin
        yield
      rescue StandardError => e
        puts "Acting on a failure resulted from:\nMessage: #{e}"
        puts "Backtrace: #{e.backtrace.join("\n")}" if Lftpsun.debug?
      end
    end
  end
end
