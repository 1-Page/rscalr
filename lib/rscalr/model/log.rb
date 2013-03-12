class Log
  attr_accessor :server_id, :message, :timestamp
  
  def to_s
    "{ type: \"log\", server_id: \"#{@server_id}\", message: \"#{@message}\", timestamp: #{@timestamp} }"
  end
end
