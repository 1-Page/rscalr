class ServerLog < Log
  attr_accessor :severity, :source
  
  def to_s
    "{ type: \"server_log\", server_id: \"#{@server_id}\", message: \"#{@message}\", timestamp: #{@timestamp}, severity: #{@severity}, source: \"#{@source}\" }"
  end
end