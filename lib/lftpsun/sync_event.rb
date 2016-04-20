module Lftpsun
  class SyncEvent
    def initialize(name, src_path, label, host)
      @params = {
        name: name,
        src_path: src_path,
        label: label,
        host: host,
      }
      @params.merge!({
        queued_at: Time.now.utc,
      })
    end

    def src_path
      @params[:src_path]
    end

    def dest_path
      dir = "#{Lftpsun.download_dir}/"
      dir += "#{@params[:label]}/" if @params[:label]
      dir += "#{@params[:name]}/" if @params[:name]
      dir
    end

    def host
      @params[:host]
    end

    def start(time = Time.now.utc)
      puts "Started processing event at #{time}" if Lftpsun.debug?
      @params = @params.merge({
        started_at: time
      })
    end

    def finish(time = Time.now.utc)
      puts "Finished processing event at #{time}" if Lftpsun.debug?
      @params = @params.merge({
        finished_at: time
      })
    end

    def to_s
      "SyncEvent <#{self.hash}>: [#{@params.to_s}]"
    end
  end
end
