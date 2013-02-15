class Log
  attr_accessor :server_id, :message, :severity, :timestamp, :source
  
  def to_s
    "{ type: \"log\", server_id: \"#{@server_id}\", message: \"#{@message}\", severity: #{@severity}, timestamp: #{@timestamp}, source: \"#{@source}\" }"
  end
end
