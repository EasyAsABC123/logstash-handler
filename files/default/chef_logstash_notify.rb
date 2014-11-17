require "json"
require "socket"
require "pp"

module LogStash
  class LogStashNotify < Chef::Handler

    def report
      if @unique_message != ''
        Chef::Log.info("Chef run @ #{@timestamp}, informing chefs via Log Stash")
        message_log_stash
      end
    end

    private
      class LogMessage
        def initialize(hostname, message, timestamp)
          @hostname=hostname
          @message=message
          @timestamp=timestamp
        end

        def to_json
          {'hostname' => @hostname, 'message' => @message, 'timestamp' => @timestamp}.to_json
        end
      end

      attr_writer :host,:port

      def initialize(options = {})
        @host = options[:host]
        @port = options[:port]
        @godeploylog=options[:godeploylog]
        @unique_message = options[:unique_message]
        @timestamp = Time.now.getutc
      end

      def formatted_run_list
        node.run_list.map { |r| r.type == :role ? r.name : r.to_s }.join(", ")
      end

      def message_log_stash
        message = String.new
        message << "Go deployment id: #{@unique_message}\n"
        message << "Chef run on #{node.name} (#{formatted_run_list})\n"
        message << "Exception: #{run_status.formatted_exception}\n\n" if run_status.formatted_exception != ""
        message << Array(run_status.backtrace).join("\n") if Array(run_status.backtrace).size > 0
        begin
        File.open(@godeploylog, "r:bom|utf-8:ascii"){|f|
          message << f.read
        }
        rescue EOFError
        rescue IOError => e
          Chef::Log.warn("Got IOError reading #{@godeploylog}")
        rescue Errno::ENOENT
          Chef::Log.warn("Cannot open #{@godeploylog}")
        end

        logmessage = LogMessage.new(node.name, message, @timestamp)
        begin
          timeout(10) do
              s = TCPSocket.new("#{@host}", @port)
              s.write(logmessage.to_json)
              s.close
          end
          Chef::Log.info("Informed chefs via Log Stash: #{message}")
        rescue ::Timeout::Error
          Chef::Log.warn("Timed out while attempting to message chefs via Log Stash")
        rescue => error
          Chef::Log.warn("Unexpected error while attempting to message chefs via Log Stash : #{error}")
        end
      end
  end
end