class Dashboard

  def initialize(config=nil)
    if config.is_a?(Scalr)
      @client = config
    elsif config.nil? || config.is_a?(Hash) 
      @client = Scalr.new(config)
    else
      raise 'Dashboard may only be initialized with a config Hash, Scalr object, or nil (load config from environment)'
    end
    
    @env_id = @client.env_id
  end
  
  def get_farm(name)
    if @farms.nil?
      load_farms
    end
    @farms[name]
  end
  
  def get_farm_by_id(farm_id)
    if @farms.nil?
      load_farms
    end
    @farms.each { |name,farm|
      return farm if farm.id == farm_id
    }
    
    nil
  end
  
  def load_farms
    @farms = {}
    
    scalr_response = @client.farms_list
    scalr_response.root.each_element('FarmSet/Item') { |row| 
      farm = Farm.new @client
      
      row.each_element { |prop| 
        if "ID" == prop.name
          farm.id = prop.text
        elsif "Name" == prop.name
          farm.name = prop.text
        elsif "Status" == prop.name
          farm.status = prop.text
        end
      }
      @farms[farm.name] = farm
    }
    
    @farms
  end
  
  def get_script(name)
    if @scripts.nil?
      load_scripts
    end
    @scripts[name]
  end
  
  def load_scripts
    @scripts = {}
    
    scalr_response = @client.scripts_list
    scalr_response.root.each_element('ScriptSet/Item') { |row| 
      script = Script.new @client
      
      row.each_element { |prop| 
        if "ID" == prop.name
          script.id = prop.text
        elsif "Name" == prop.name
          script.name = prop.text
        elsif "Description" == prop.name
          script.description = prop.text
        elsif "LatestRevision" == prop.name
          script.latest_revision = prop.text.to_i
        end
      }
      @scripts[script.name] = script
    }
    
    @scripts
  end
  
  def get_environment(name)
    if @environments.nil?
      load_environments
    end
    @environments[name]
  end
  
  def load_environments
    @environments = {}
    
    scalr_response = @client.environments_list
    scalr_response.root.each_element('EnvironmentSet/Item') { |row| 
      environment = Environment.new
      
      row.each_element { |prop| 
        if "ID" == prop.name
          environment.id = prop.text
        elsif "Name" == prop.name
          environment.name = prop.text
        end
      }
      @environments[environment.name] = environment
    }
    
    @environments
  end
  
  def get_role(name)
    if @roles.nil?
      load_roles
    end
    @roles[name]
  end
  
  def load_roles
    @roles = {}
    
    scalr_response = @client.roles_list
    scalr_response.root.each_element('RoleSet/Item') { |row| 
      role = Role.new
      
      row.each_element { |prop| 
        if "ID" == prop.name
          role.id = prop.text
        elsif "Name" == prop.name
          role.name = prop.text
        end
      }
      @roles[role.name] = role
    }
    
    @roles
  end

  # Blocks up to timeout seconds waiting on log response(s) of script execution. Returns true iff 
  # script executed successfully (returned) exit_value on all servers.
  def verify_script_success(script_execution, exit_value=0, timeout_sec=60)
    return false unless script_execution.success?
    
    sleep_time = 5
    
    start_time = Time.now.to_i
    
    # 1. get list of servers that this execution should run on
    farm = get_farm_by_id(script_execution.farm_id)
    if !script_execution.server_id.nil? 
      server = farm.get_server(script_execution.server_id)
      script_execution.add_server(server.server_id)
    elsif !script_execution.farm_role_id.nil?
      role_servers = farm.get_servers_for_role_id(script_execution.farm_role_id) 
      role_servers.each { |server|
        script_execution.add_server(server.server_id)
      }
    else
      farm_servers = farm.get_all_servers
      farm_servers.each { |server|
        script_execution.add_server(server.server_id)
      }
    end
        
    # 2. Call logs list and match results to server IDs
    success = false
    finished = false
    begin
      start = 0
      begin
        loglist = farm.load_script_logs(script_execution.server_id, script_execution.event_id, start, 20)
        total_records = loglist.total_records
    
        loglist.each { |log|
          script_execution.set_server_result(log)
          start += 1
        }
      end while start < total_records
    
      # 3. If not all servers have responses logged, repeat Step 2 until done or timeout_sec seconds have expired
      success = true
      finished = true
      script_execution.server_results.each { |server_id, result|
        success &&= (!result.nil? && result.exec_exit_code == exit_value)
        finished &&= !result.nil?
      }
    end while !finished && (Time.now.to_i - start_time) < (timeout_sec + sleep_time) && sleep(sleep_time)
    
    success
  end
  
  def verbose= setting
    @client.verbose = setting
  end
end