require 'rscalr'
require 'test/unit'

class TestObjLogs < Test::Unit::TestCase
  
  def setup
    @scalr = Scalr.new({
      :key_id => ENV['SCALR_TEST_API_KEY'], 
      :key_secret => ENV['SCALR_TEST_API_SECRET'], 
      :env_id => ENV['SCALR_TEST_ENV_ID'] 
    })
      
    @dashboard = Dashboard.new @scalr
    
    @farm_test1_name = 'test1'
  end
  
  def test_list_launch_details_terminate
    farm = @dashboard.get_farm(@farm_test1_name)
    
    assert_not_nil(farm, "Test farm not found by name")
    
    loglist = farm.load_logs
    
    assert_not_nil(loglist, "Log list could not be loaded")
    assert_equal(0, loglist.total_records, "Test farm 1 should not have any logs associated with it")
    
  end
  
end