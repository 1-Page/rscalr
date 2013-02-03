require 'rscalr'
require 'test/unit'

class TestClientFarms < Test::Unit::TestCase
  
  def setup
    @scalr = Scalr.new({ :key_id => ENV['SCALR_TEST_API_KEY'], :key_secret => ENV['SCALR_TEST_API_SECRET'] })
    @farm_test1_name = 'test1'
  end
  
  def test_list_launch_details_terminate
    
    # List
    api_result = @scalr.farms_list
    assert(api_result.success?, "FarmsList failed with message #{api_result.error_message}")
    api_result.root.each_element('FarmSet/Item') do |ele|
      if ele.elements['Name'].text == @farm_test1_name
        $FARM_TEST1_ID = ele.elements['ID'].text.to_i
        assert ele.elements['Status'].text == '0', "Test Farm 1 is not currently down! Please stop it manually and rerun tests." 
      end
    end
    
    assert_not_nil $FARM_TEST1_ID, "Test Farm 1 not found!"
    
    # Launch
    api_result = @scalr.farm_launch $FARM_TEST1_ID
    assert api_result.success?, "FarmLaunch failed with message #{api_result.error_message}"
    
    # GetDetails
    api_result = @scalr.farm_get_details $FARM_TEST1_ID
    assert api_result.success?, "FarmGetDetails failed with message #{api_result.error_message}"
    
    sleep(5)
    
    # Terminate
    api_result = @scalr.farm_terminate $FARM_TEST1_ID, false, false, false
    assert api_result.success?, "FarmTerminate failed with message #{api_result.error_message}"
  end
  
end