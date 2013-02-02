class Farm
  attr_accessor :id, :name, :status
    
  def initialize client
    @client = client
  end
  
  def get_role(name)
    if @farm_roles.nil?
      load_details
    end
    @farm_roles[name]
  end
  
  def load_details 
    @farm_roles = {}
    
    scalr_response = @client.farm_get_details @id
    scalr_response.root.each_element('FarmRoleSet/Item') { |row| 
      role = FarmRole.new 
      
      row.each_element { |prop| 
        if "ID" == prop.name
          role.farm_role_id = prop.text
        elsif "RoleID" == prop.name
          role.role_id = prop.text
        elsif "Name" == prop.name
          role.name = prop.text
        elsif "ServerSet" == prop.name
          prop.each_element { |server_element| 
            server = Server.new
            server.role = role
            
            server_element.each_element { |server_prop| 
              if "ServerID" == prop.name
                server.server_id = prop.text
              elsif "ExternalIP" == prop.name
                server.external_ip = prop.text
              elsif "InternalIP" == prop.name
                server.external_ip = prop.text
              elsif "Status" == prop.name
                server.status = prop.text
              elsif "Index" == prop.name
                server.index = prop.text.to_i
              elsif "Uptime" == prop.name
                server.uptime = prop.text.to_f
              end
            }
            role.servers << server
          }
        end
      }
      
      @farm_roles[role.name] = role
    }
    
    @farm_roles
  end
  
  def to_s
    "{ type: \"farm\", id: #{@id}, name: \"#{@name}\", status: #{@status} }"
  end
end

