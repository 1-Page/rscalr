require 'openssl'
require 'net/http'
require 'cgi'
require 'rexml/document'

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
  
  def generate_sig(action, timestamp)
    message = action + ':' + @config[:key_id] + ':' + timestamp
    hexdigest = OpenSSL::HMAC.hexdigest('sha256', @config[:key_secret], message)
    [[hexdigest].pack("H*")].pack("m0")
  end
  
  def execute_api_call(action, action_params=nil)
  
    begin
  	  params = { :Action => action, :TimeStamp => Time.now.strftime("%Y-%m-%dT%H:%M:%SZ") }
	    params.merge!(action_params) unless action_params.nil?
		
  	  params[:Signature] = generate_sig(action, params[:TimeStamp])
  	  params[:Version] = @config[:version]
  	  params[:AuthVersion] = @config[:auth_version]
  	  params[:KeyID] = @config[:key_id]
			
  	  uri = URI("https://api.scalr.net/?" + hash_to_querystring(params))
	
	    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
  	    request = Net::HTTP::Get.new uri.request_uri
  	    http.request request # Net::HTTPResponse object
  	  end
	  
  	  case response
  	  when Net::HTTPSuccess then
          result = ScalrResponse.new response.body
  	  else
  	    result = build_error_response(response)
  	  end
	  
  	rescue => ex
  	  result = build_error_response(ex.message)
  	end

    result
  end
  
  def build_error_response(message)
    result = ScalrResponse.new "<?xml version='1.0?>"
    result.add_element("Error")
    ele = REXML::Element.new "TransactionID"
    ele.text = generate_sig(message, Time.now.strftime("%Y-%m-%dT%H:%M:%SZ"))
    result.root.elements << ele
    ele = REXML::Element.new "Message"
    ele.text = message
    result.root.elements << ele

	result
  end
  
  def hash_to_querystring(h)
    h.map{|k,v| "#{k.to_s}=#{CGI::escape(v.to_s)}"}.join('&')
  end
  
  
  #=================== API Section ===================================
  
  def farms_list
    execute_api_call('FarmsList')
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
end

class ScalrResponse < REXML::Document
  
  def initialize http_response_body=nil
    if http_response_body.nil?
      super
    else
      super http_response_body
    end
  end
    
  def success?
    root.name != 'Error'
  end
  
  def error_message
    if success?
      nil
    else
      root.elements['Message'].text
    end
  end
end

