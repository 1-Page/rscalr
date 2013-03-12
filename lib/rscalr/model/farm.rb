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
  
  def get_server(name)
    if @farm_servers.nil?
      load_details
    end
    @farm_servers[name]
  end
  
  def get_servers_for_role_id(farm_role_id)
    if @farm_roles.nil?
      load_details
    end
    result = []
    @farm_roles.each { |name,role|
      result = role.servers.dup if role.farm_role_id == farm_role_id
    }
    result
  end
  
  def get_all_servers
    if @farm_roles.nil?
      load_details
    end
    result = []
    @farm_roles.each { |name,role|
      role.servers.each { |server|
        result << server
      }
    }
    result
  end
  
  def load_details 
    @farm_roles = {}
    @farm_servers = {}
    
    scalr_response = @client.farm_get_details @id
    scalr_response.root.each_element('FarmRoleSet/Item') { |row| 
      role = FarmRole.new 
      
      row.each_element { |prop| 
        if "ID" == prop.name
          role.farm_role_id = prop.text.to_i
        elsif "RoleID" == prop.name
          role.role_id = prop.text.to_i
        elsif "Name" == prop.name
          role.name = prop.text
        elsif "ServerSet" == prop.name
          prop.each_element { |server_element| 
            server = Server.new
            server.role = role
            
            server_element.each_element { |server_prop| 
              if "ServerID" == server_prop.name
                server.server_id = server_prop.text
              elsif "ExternalIP" == server_prop.name
                server.external_ip = server_prop.text
              elsif "InternalIP" == server_prop.name
                server.external_ip = server_prop.text
              elsif "Status" == server_prop.name
                server.status = server_prop.text
              elsif "Index" == server_prop.name
                server.index = server_prop.text.to_i
              elsif "Uptime" == server_prop.name
                server.uptime = server_prop.text.to_f
              end
            }
            role.servers << server
            @farm_servers[server.server_id] = server
          }
        end
      }
      
      @farm_roles[role.name] = role
    }
    
    @farm_roles
  end
  
  # Loads a Loglist of Log entries for the farm, given the specified parameters
  def load_logs(server_id=nil, start=nil, limit=nil)
    scalr_response = @client.logs_list(@id, server_id, start, limit)
    loglist = LogList.new
    
    scalr_response.root.each_element do |element|
      if "TotalRecords" == element.name
        loglist.total_records = element.text.to_i
      elsif "StartFrom" == element.name
        loglist.start = element.text.to_i
      elsif "RecordsLimit" == element.name
        loglist.limit = element.text.to_i
      elsif "LogSet" == element.name
        element.each_element do |item|
          log = ServerLog.new

          item.each_element do |prop| 
            if "ServerID" == prop.name
              log.server_id = prop.text
            elsif "Message" == prop.name
              log.message = prop.text
            elsif "Severity" == prop.name
              log.severity = prop.text.to_i
            elsif "Timestamp" == prop.name
              log.timestamp = prop.text.to_i
            elsif "Source" == prop.name
              server.source = prop.text
            end
          end
          loglist << log
        end
      end
    end
    
    loglist
  end
  
  # Loads script execution logs for the farm, or a particular server in the farm, optionally relating to a particular script execution.
  def load_script_logs(server_id=nil, event_id=nil, start=nil, limit=nil)
    scalr_response = @client.scripting_logs_list(@id, server_id, event_id, start, limit)
    loglist = LogList.new
    
    scalr_response.root.each_element do |element|
      if "TotalRecords" == element.name
        loglist.total_records = element.text.to_i
      elsif "StartFrom" == element.name
        loglist.start = element.text.to_i
      elsif "RecordsLimit" == element.name
        loglist.limit = element.text.to_i
      elsif "LogSet" == element.name
        element.each_element do |item|
          log = ScriptLog.new

          item.each_element do |prop| 
            if "ServerID" == prop.name
              log.server_id = prop.text
            elsif "Message" == prop.name
              log.message = prop.text
            elsif "ScriptName" == prop.name
              log.script_name = prop.text
            elsif "Timestamp" == prop.name
              log.timestamp = prop.text.to_i
            elsif "ExecTime" == prop.name
              log.exec_time = prop.text.to_i
            elsif "ExecExitCode" == prop.name
              log.exec_exit_code = prop.text.to_i
            elsif "Event" == prop.name
              log.event = prop.text
            end
          end
          loglist << log
        end
      end
    end
    
    loglist
  end
  
  def to_s
    "{ type: \"farm\", id: #{@id}, name: \"#{@name}\", status: #{@status} }"
  end
end

