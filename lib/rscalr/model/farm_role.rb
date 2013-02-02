class FarmRole < Role
  attr_accessor :farm_role_id, :servers
  
  def initialize
    @servers = []
  end
  
  def to_s
    "{ type: \"farm_role\", farm_role_id: #{@farm_role_id}, role_id: #{@role_id}, name: \"#{@name}\", num_servers: #{@servers.size} }"
  end
  
end
