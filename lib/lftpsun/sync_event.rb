module Lftpsun
  class SyncEvent
    def initialize(params = {})
      @params = params.merge({
        queued_at: Time.now.utc,
      })
    end

    def src_path
      @params['path']
    end

    def dest_path
      "#{Lftpsun.download_dir}/#{@params['label']}/"
    end

    def host
      @params['host']
    end

    def start(time = Time.now.utc)
      puts "Started processing event at #{time}" if DEBUG
      @params = params.merge({
        started_at: time
      })
    end

    def finish(time = Time.now.utc)
      puts "Finished processing event at #{time}" if DEBUG
      @params = params.merge({
        finished_at: time
      })
    end

    def to_s
      "SyncEvent <#{self.hash}>: [#{@params.to_s}]"
    end
  end
end
