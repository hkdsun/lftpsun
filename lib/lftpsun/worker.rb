module Lftpsun
  class Worker
    def initialize(event)
      @event = event
      @lftp = LFTP.new(
        source: @event.src_path,
        destination: @event.dest_path,
        host: @event.host
      )
    end

    def work
      @event.start
      do_work
    ensure
      @event.finish
    end

    private

    def do_work
      @lftp.run
    end
  end
end
