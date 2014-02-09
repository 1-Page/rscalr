class ScriptExecution
  attr_reader :script_id, :result, :event_id, :farm_id, :farm_role_id, :server_id, :server_results
  
  def initialize(script_id, result, event_id, farm_id, farm_role_id=nil, server_id=nil)
    @script_id = script_id
    @result = result
    @result = 0 if @result != 1
    @event_id = event_id
    @farm_id = farm_id
    @farm_role_id = farm_role_id
    @server_id = server_id
    
    # instance field to store execution results
    @server_results = {}
  end
  
  def success?
    @result == 1
  end
  
  def add_server(server_id)
    @server_results[server_id] = nil
  end
  
  def set_server_result(log)
    @server_results[log.server_id] = log if @server_results.has_key?(log.server_id)
  end
  
  def to_s
    "{ type: \"script_execution\", script_id: #{@script_id}, result: #{@result}, event_id: \"#{@event_id}\"}"
  end
end

class ScriptExecutionServerResult
  attr_accessor :script_id, :server_id, :log
  
  def initialize(script_id, server_id)
    @script_id = script_id
    @server_id = server_id
  end
  
  def to_s
    "{ type: \"script_execution_server_result\", script_id: #{@script_id}, server_id: \"#{@server_id}\", result: #{@log} }"
  end
end