require 'rscalr/model/farm'
require 'rscalr/model/script'

class Dashboard
  
  def initialize client
    @client = client
  end
  
  def get_farm(name)
    if @farms.nil?
      load_farms
    end
    @farms[name]
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
end