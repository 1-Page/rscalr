require 'time'

class Script
  attr_accessor :id, :name, :description, :latest_revision, :details
  
  def initialize client
    @client = client
  end
  
  def execute(farm_id, timeout=30, async=:no_async, farm_role_id=nil, server_id=nil, revision=nil, config_vars=nil)
    set_revision(revision) # Side effect!
    @client.script_execute farm_id, @id, timeout, async, farm_role_id, server_id, @revision, config_vars
  end
  
  def load_details
    @details = ScriptDetails.new @id
    scalr_response = @client.script_get_details @id
    scalr_response.root.each_element('ScriptRevisionSet/Item') { |row| 
      revision = ScriptRevision.new
      
      row.each_element { |prop| 
        if "Revision" == prop.name
          revision.revision = prop.text.to_i
        elsif "Date" == prop.name
          revision.date = Time.parse(prop.text)
        elsif "ConfigVariables" == prop.name
          prop.each_element { |configvar_element| 
            configvar_element.each_element { |configvar_prop| 
              if "Name" == prop.name
                revision.config_variables << prop.text
              end
            }
          }
        end
      }

      @details.revisions[revision.revision] = revision
    }
    
    @details
  end
  
  def get_config_variables
    load_details unless @details != nil
    @revision = @latest_revision unless @revision != nil
    puts "Rev: #{@revision} -- Deets: #{@details}"
    @details.revisions[@revision].config_variables
  end
  
  def set_revision(revision)
    if revision.nil? || revision >= @latest_revision
      @revision = @latest_revision
    elsif revision < 1
      @revision = 1
    else
      @revision = revision
    end
  end
  
  def to_s
    "{ type: \"script\", id: #{@id}, name: \"#{@name}\" }"
  end
end

class ScriptDetails
  attr_accessor :id, :revisions
  
  def initialize id
    @id = id
    @revisions = {}
  end
  
  def to_s
    "{ type: \"script-details\", script_id: #{@id}, num_revisions: #{@revisions.size}}"
  end
end

class ScriptRevision
  attr_accessor :revision, :date, :config_variables
  
  def initialize
    @config_variables = []
  end
  
  def to_s
    "{ type: \"script-revision\", revision: #{@revision}, date: \"#{@date}\", vars: \"#{@config_variables}\"}"
  end
end