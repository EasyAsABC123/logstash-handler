require "chef/handler"
require "json"
require "socket"
require "pp"

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

class LogStashNotify < Chef::Handler
  attr_writer :host,:port

  def initialize(options = {})
    @host = options[:host]
    @port = options[:port]
    @unique_message = options[:unique_message]
    @timestamp = Time.now.getutc
  end

  def formatted_run_list
    node.run_list.map { |r| r.type == :role ? r.name : r.to_s }.join(", ")
  end

  def message_log_stash
    message = ''
    message += "Go run id: #{@unique_message} \n" if @unique_message != ''
    message += "Chef failed on #{node.name} (#{formatted_run_list}) with: \n"
    message += "#{run_status.formatted_exception}\n"
    message += "#{run_status.backtrace}"
    logmessage = LogMessage.new(node.name, message, @timestamp)
    begin
      timeout(10) do
          s = TCPSocket.new("#{@host}", @port)
          s.write(logmessage.to_json)
          s.close
      end
      Chef::Log.info("Informed chefs via Log Stash: #{message}")
    rescue Timeout::Error
      Chef::Log.error("Timed out while attempting to message chefs via Log Stash")
    rescue => error
      Chef::Log.error("Unexpected error while attempting to message chefs via Log Stash : #{error}")
    end
  end

  def report
    if run_status.failed? && !STDOUT.tty?
    # use below for debugging from the console
    #if run_status.failed?
      Chef::Log.error("Chef run failed @ #{@timestamp}, informing chefs via Log Stash")
      message_log_stash
    end
  end
end