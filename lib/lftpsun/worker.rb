module Lftpsun
  class Worker
    def initialize(event)
      @event = event
      @job_params = event.job_params
    end

    def do_work
      LFTP.new(
        source: @event.src_path,
        destination: @event.dest_path,
        host: @event.host
      ).run
    end

    def work
      @event.start
      do_work
    ensure
      @event.finish
    end
  end
end
