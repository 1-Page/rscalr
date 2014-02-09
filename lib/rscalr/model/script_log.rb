class ScriptLog < Log
  attr_accessor :script_name, :exec_time, :exec_exit_code, :event
  
  def to_s
    "{ type: \"script_log\", server_id: \"#{@server_id}\", script_name: \"#{@script_name}\", message: \"#{@message}\", timestamp: #{@timestamp}, exec_exit_code: #{@exec_exit_code} }"
  end
end