class Server
  attr_accessor :server_id, :external_ip, :internal_ip, :status, :index, :uptime, :role
  
  def to_s
    "{ type: \"server\", id: \"#{@server_id}\", external_ip: \"#{@external_ip}\", internal_ip: \"#{@internal_ip}\", role: #{@role} }"
  end
end