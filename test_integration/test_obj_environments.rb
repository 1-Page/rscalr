require 'rscalr'
require 'test/unit'

class TestObjEnvironments < Test::Unit::TestCase
  
  def setup
    @scalr = Scalr.new({
      :key_id => ENV['SCALR_TEST_API_KEY'], 
      :key_secret => ENV['SCALR_TEST_API_SECRET'], 
      :env_id => ENV['SCALR_TEST_ENV_ID'] 
    })
      
    @dashboard = Dashboard.new @scalr
  end
  
  def test_list_launch_details_terminate
    environment = @dashboard.get_environment(ENV['SCALR_TEST_ENV_NAME'])
    
    assert_not_nil(environment, "Test environment not found by name")
    assert_equal(ENV['SCALR_TEST_ENV_ID'], environment.id)
    assert_equal(ENV['SCALR_TEST_ENV_NAME'], environment.name)
  end
  
end