require 'rscalr'
require 'test/unit'

class TestClientFarms < Test::Unit::TestCase
  
  def setup
    @scalr = Scalr.new({ :key_id => ENV['SCALR_TEST_API_KEY'], :key_secret => ENV['SCALR_TEST_API_SECRET'] })
    @farm_test1_name = 'test1'
  end
  
  def test_list_launch_details_terminate
    farm_test1_id = nil
    
    # List
    api_result = @scalr.farms_list
    assert(api_result.success?, "FarmsList failed with message #{api_result.error_message}")
    api_result.root.each_element('FarmSet/Item') do |ele|
      if ele.elements['Name'].text == @farm_test1_name
        farm_test1_id = ele.elements['ID'].text.to_i
        assert ele.elements['Status'].text == '0', "Test Farm 1 is not currently down! Please stop it manually and rerun tests." 
      end
    end
    
    assert_not_nil farm_test1_id, "Test Farm 1 not found!"
    
    # Launch
    api_result = @scalr.farm_launch farm_test1_id
    assert api_result.success?, "FarmLaunch failed with message #{api_result.error_message}"
    
    # GetDetails
    api_result = @scalr.farm_get_details farm_test1_id
    assert api_result.success?, "FarmGetDetails failed with message #{api_result.error_message}"
    
    sleep(5)
    
    # Terminate
    api_result = @scalr.farm_terminate farm_test1_id, false, false, false
    assert api_result.success?, "FarmTerminate failed with message #{api_result.error_message}"
  end
  
end