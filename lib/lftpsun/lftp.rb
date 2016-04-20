require 'pty'
require 'fileutils'

module Lftpsun
  class LFTP
    class SyncError < StandardError; end

    def initialize(
      source: nil,
      destination: nil,
      host: nil,
      port: nil,
      clear_src_dir: false,
      log: true
    )
      raise ArgumentError, "Insufficient arguments to build an lftp command" unless host && source && destination

      @host = host
      @source = source
      @destination = destination
      @port = port
      @remove_src = clear_src_dir
      @logging = log
      @debug = Lftpsun.debug?
      @command = build_lftp_command
    end

    def run
      maybe_create_destination
      spawn_command
    rescue PTY::ChildExited => e
      raise LFTPSync::SyncError, "lftp process exited unexpectedly"
    end

    def self.progress_log_file
      File.expand_path("#{log_dir}/progress.log")
    end

    def self.log_dir
      Lftpsun.config['lftp_log_dir']
    end

    private

    def build_lftp_command
      stdin = <<-EOF
        set ftp:ssl-protect-data true
        set ftps:initial-prot
        set ftp:ssl-force true
        set ftp:ssl-protect-data true
        set ssl:verify-certificate off
        set net:max-retries 1
        set dns:max-retries 1
        set mirror:use-pget-n #{parallelization_factor}
        mirror #{"--Remove-source-files" if @remove_src} -c -P#{parallelization_factor} #{"--log=#{LFTP.log_dir}/syncmyshit_lftp.log" if logging?} #{@source.shellescape} #{@destination.shellescape}
        quit
      EOF
      cmd = "lftp sftp://#{@host.shellescape} #{"-p #{@port}" if @port}"
      [cmd, stdin]
    end

    def parse_line(line)
      # format reference:
      # `Adventure Time - 203b - Slow Love {C_P} (720p).mkv', got 147624467 of 173127299 (85%) 3.93M/s eta:22s
      re = /`(.*)',\sgot\s(.*)\sof\s(.*)\s\((.*)\)\s([0-9M\/s\.]*)\seta:(.*)/
      match = line.match(re)
      if match
        {
          filename: match[1],
          downloaded: match[2],
          total: match[3],
          progress: match[4],
          speed: match[5],
          eta: match[6],
        }
      end
    end

    def spawn_command
      run_cmd, lftp_cmd = build_lftp_command
      PTY.spawn(run_cmd) do |reader, writer, pid|
        begin
          log_to_file("[LFTP-SYNC] starting lftp on PID: #{pid} with arguments\n#{lftp_cmd}")
          writer.puts lftp_cmd
          reader.each do |line|
            log_to_file(line)
          end
        rescue Errno::EIO
          log_to_file("[LFTP-SYNC] no more output")
        ensure
          log_to_file("[LFTP-SYNC] killing PID: #{pid}")
          Process.kill('KILL', pid)
        end
      end
    end

    def parallelization_factor
      Lftpsun.config['lftp']['parallel_factor']
    end

    def log_to_file(line)
      open(LFTP.progress_log_file, 'a') do |f|
        f << line << "\n"
      end
    end

    def logging?
      @logging
    end

    def maybe_create_destination
      dirname = File.expand_path(@destination)
      puts "[LFTP-SYNC] creating directory #{dirname}"
      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end
    end
  end
end
