require 'openssl'
require 'net/http'
require 'cgi'
require 'rexml/document'

# Low-level Scalr API client. Instantiated with a hash containing config parameters (:key_id and :key_secret). 
# All API methods are implemented as methods that return a ScalrResponse object. This object inherits from 
# REXML::Document, making accessing the results pretty straightforward. 
#
# Unexpected errors (network, etc.) are also wrapped in an ad hoc ScalrResponse, with the transacation ID 
# equal to 'sig:' + [signature used to sign the request] and the message equal to the error message.
class Scalr
  attr_accessor :config
  
  # Default versions
  $DEFAULT_VERSION = '2.3.0'
  $DEFAULT_AUTH_VERSION = '3'
  
  def initialize(config)
    @config = config
    @config[:version] = $DEFAULT_VERSION if @config[:version].nil?
    @config[:auth_version] = $DEFAULT_AUTH_VERSION if @config[:auth_version].nil?
  end
  
  #=================== API Section ===================================
  
  def apache_vhost_create(domain_name, farm_id, farm_role_id, document_root_dir, enable_ssl, ssl_private_key=nil, ssl_certificate=nil)
    params = { 
      :DomainName => domain_name,
      :FarmID => farm_id, 
      :FarmRoleID => farm_role_id,
      :DocumentRootDir => document_root_dir, 
      :EnableSSL => enable_ssl 
    }
    params[:SSLPrivateKey] = ssl_private_key unless ssl_private_key.nil?
    params[:SSLCertificate] = ssl_certificate unless ssl_certificate.nil?
    
    execute_api_call('ApacheVhostCreate', params)
  end
  
  def apache_vhosts_list
    execute_api_call('ApacheVhostsList')
  end
  
  def bundle_task_get_status(bundle_task_id)
    params = { :BundleTaskID => bundle_task_id }
    
    execute_api_call('BundleTaskGetStatus', params)
  end
  
  def dm_application_deploy(application_id, farm_role_id, remote_path)
    params = { :ApplicationID => application_id, :FarmRoleID => farm_role_id, :RemotePath => remote_path }

    execute_api_call('DmApplicationDeploy', params)
  end
  
  def dm_applications_list
    execute_api_call('DmApplicationsList')
  end
  
  def dm_sources_list
    execute_api_call('DmSourcesList')
  end
  
  def dns_zone_create(domain_name, farm_id=nil, farm_role_id=nil)
    params = { :DomainName => domain_name }
    params[:FarmID] = farm_id unless farm_id.nil?
    params[:FarmRoleID] = farm_role_id unless farm_role_id.nil?
    
    execute_api_call('DNSZoneCreate', params)
  end
  
  def dns_zone_record_add(zone_name, type, ttl, name, value, priority=nil, weight=nil, port=nil)
    params = { 
      :ZoneName => zone_name,
      :Type => type, 
      :TTL => ttl,
      :Name => name, 
      :Value => value 
    }
    params[:Priority] = priority unless priority.nil?
    params[:Weight] = weight unless weight.nil?
    params[:Port] = port unless port.nil?
    
    execute_api_call('DNSZoneRecordAdd', params)
  end
  
  def dns_zone_record_remove(zone_name, record_id)
    params = { :ZoneName => zone_name, :RecordID => record_id }
    
    execute_api_call('DNSZoneRecordRemove', params)
  end
  
  def dns_zone_records_list(zone_name)
    params = { :ZoneName => zone_name }
    
    execute_api_call('DNSZoneRecordsList', params)
  end
  
  def dns_zones_list    
    execute_api_call('DNSZonesList')
  end
  
  def environments_list    
    execute_api_call('EnvironmentsList')
  end
  
  def events_list(farm_id, start=nil, limit=nil)
    params = { :FarmID => farm_id }
    params[:StartFrom] = start unless start.nil?
    params[:RecordsLimit] = limit unless limit.nil?
    
    execute_api_call('EventsList', params)
  end
  
  def farm_clone(farm_id)
    params = { :FarmID => farm_id }

    execute_api_call('FarmClone', params)
  end
  
  def farm_get_stats(farm_id, date)
    params = { :FarmID => farm_id }
    params[:Date] = date.strftime("%m-%Y") unless date.nil?

    execute_api_call('FarmGetStats', params)
  end
  
  def farm_launch(farm_id)
    params = { :FarmID => farm_id }

    execute_api_call('FarmLaunch', params)
  end
  
  def farms_list
  
    execute_api_call('FarmsList')
  end
  
  def farm_terminate(farm_id, keep_ebs, keep_eip, keep_dns_zone)
    params = { 
      :FarmID => farm_id,
      :KeepEBS => (keep_ebs ? 1 : 0), 
      :KeepEIP => (keep_eip ? 1 : 0), 
      :KeepDNSZone => (keep_dns_zone ? 1 : 0)
    }
    
    execute_api_call('FarmTerminate', params)
  end
  
  def logs_list(farm_id, server_id=nil, start=nil, limit=nil)
    params = { :FarmID => farm_id }
    params[:ServerID] = server_id unless server_id.nil?
    params[:StartFrom] = start unless start.nil?
    params[:RecordsLimit] = limit unless limit.nil?
    
    execute_api_call('LogsList', params)
  end
  
  def roles_list(platform=nil, name=nil, prefix=nil, image_id=nil)
    params = {}
    params[:Platform] = platform unless platform.nil?
    params[:Name] = name unless name.nil?
    params[:Prefix] = prefix unless prefix.nil?
    params[:ImageID] = image_id unless image_id.nil?

	execute_api_call('RolesList', params)
  end
  
  def scripts_list
    execute_api_call('ScriptsList')
  end
  
  def farm_get_details(farm_id)
    execute_api_call('FarmGetDetails', { :FarmID => farm_id })
  end
  
  def script_execute(farm_id, script_id, timeout=30, async=:no_async, farm_role_id=nil, server_id=nil, revsion=nil, config_vars=nil)
    async_int = 0 
    async_int = 1 if async == :async
    
    params = { :FarmID => farm_id, :ScriptID => script_id, :Timeout => timeout, :Async => async_int }
    params[:FarmRoleID] = farm_role_id unless farm_role_id.nil?
    params[:ServerID] = server_id unless server_id.nil?
    params[:Revision] = revsion unless revsion.nil?
    if config_vars != nil 
      config_vars.each {|key, value| 
        params["ConfigVariables[#{CGI::escape(key)}]"] = value
      }
    end
    
    execute_api_call('ScriptExecute', params)
  end
  
  def script_get_details(script_id)
    execute_api_call('ScriptGetDetails', { :ScriptID => script_id })
  end
  
  def server_image_create(server_id, role_name)
    params = { :ServerID => server_id, :RoleName => role_name }
    
    execute_api_call('ServerImageCreate', params)
  end
  
  def server_launch(farm_role_id, increase_max_instances=nil)
    params = { :FarmRoleID => farm_role_id }
    params[:IncreaseMaxInstances] = (increase_max_instances ? 1 : 0) unless increase_max_instances.nil?
  
  	execute_api_call('ServerLaunch', params)
  end
  
  def server_reboot(server_id)
  	params = { :ServerID => server_id }

  	execute_api_call('ServerReboot', params)
  end
  
  def server_terminate(server_id, decrease_min_instances=nil)
    params = { :ServerID => server_id }
    params[:DecreaseMinInstancesSetting] = (decrease_min_instances ? 1 : 0) unless decrease_min_instances.nil?
  
  	execute_api_call('ServerTerminate', params)
  end
  
  def farm_role_parameters_list(farm_role_id)
    execute_api_call('FarmRoleParametersList', { :FarmRoleID => farm_role_id })
  end
  
  def farm_role_update_parameter_value(farm_role_id, param_name, param_value)
    execute_api_call('FarmRoleUpdateParameterValue', { :FarmRoleID => farm_role_id, :ParamName => param_name, :ParamValue => param_value })
  end

  def scripting_logs_list(farm_id, server_id=nil, start=nil, limit=nil)
    params = { :FarmID => farm_id }
    params[:ServerID] = server_id unless server_id.nil?
    params[:StartFrom] = start unless start.nil?
    params[:RecordsLimit] = limit unless limit.nil?
    
    execute_api_call('ScriptingLogsList', params)
  end
  
  def statistics_get_graph_url(object_type, object_id, watcher_name, graph_type)
    params = { 
      :ObjectType => object_type,
      :ObjectID => object_id, 
      :WatcherName => watcher_name,
      :GraphType => graph_type
    }
    
    execute_api_call('StatisticsGetGraphURL', params)
  end
  
  #=============== Helper methods ==================================
  
  # Generates request signature based on config, action, timestamp
  def generate_sig(action, timestamp)
    message = action + ':' + @config[:key_id] + ':' + timestamp
    hexdigest = OpenSSL::HMAC.hexdigest('sha256', @config[:key_secret], message)
    [[hexdigest].pack("H*")].pack("m0")
  end
  
  # Generates a timestamp string based on a Time object
  def generate_timestamp(time)
    time.strftime("%Y-%m-%dT%H:%M:%SZ")
  end
  
  # Executes the specified API call, passing in the specified params
  def execute_api_call(action, action_params=nil)
  
    begin
  	  params = { :Action => action, :TimeStamp => generate_timestamp(Time.now) }
	    params.merge!(action_params) unless action_params.nil?
		
  	  params[:Signature] = generate_sig(action, params[:TimeStamp])
  	  params[:Version] = @config[:version]
  	  params[:AuthVersion] = @config[:auth_version]
  	  params[:KeyID] = @config[:key_id]
  	  params[:EnvID] = @config[:env_id] unless @config[:env_id].nil?
			
  	  uri = URI("https://api.scalr.net/?" + hash_to_querystring(params))
	
	    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
  	    request = Net::HTTP::Get.new uri.request_uri
  	    http.request request # Net::HTTPResponse object
  	  end
	  
  	  case response
  	  when Net::HTTPSuccess then
          result = ScalrResponse.new response.body
  	  else
  	    result = build_error_response(response, params[:Signature])
  	  end
	  
  	rescue => ex
  	  result = build_error_response(ex.message, params[:Signature])
  	end

    result
  end
  
  # Builds an ad hoc ScalrResponse to represent an unexpected error
  def build_error_response(message, transaction_id)
    result = ScalrResponse.new "<?xml version='1.0?>"
    result.add_element("Error")
    ele = REXML::Element.new "TransactionID"
    ele.text = "sig:#{transaction_id}"
    result.root.elements << ele
    ele = REXML::Element.new "Message"
    ele.text = message
    result.root.elements << ele

	  result
  end
  
  # Turns a hash of request parameter key/value pairs into an escaped request query string.
  # Keys are expected to not require escaping.
  def hash_to_querystring(h)
    h.map{|k,v| "#{k.to_s}=#{CGI::escape(v.to_s)}"}.join('&')
  end
  
  # Changes the configured environment setting for this instance
  def env_id= env_id
    @config[:env_id] = env_id
  end
  
  # Get the current environment value. A nil response means the "first" environment will be assumed for API calls, 
  # per the Scalr API docs.
  def env_id
    @config[:env_id]
  end
  
end

# Represents a response from an API call. Thin wrapper around an REXML::Document of the parsed repsonse.
class ScalrResponse < REXML::Document
  
  def initialize http_response_body=nil
    if http_response_body.nil?
      super
    else
      super http_response_body
    end
  end
    
  # True iff the response indicates that the API call succeeded. This does not guarantee that
  # the intent of the call succeeded of course (e.g. that a script executed successfully on the Scalr side), 
  # only that Scalr reported success for the call.
  def success?
    root.name != 'Error'
  end
  
  # If the API call was not successful, this returns the inner error message.
  def error_message
    if success?
      nil
    else
      root.elements['Message'].text
    end
  end
  
  # Convenience method to output a repsonse to a stream in a human readable format
  def pretty_print(dest=$stdout)
    write(dest, 1)
  end
end

