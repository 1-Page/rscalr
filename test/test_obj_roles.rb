require 'rscalr'
require 'test/unit'

class TestObjRoles < Test::Unit::TestCase
  
  def setup      
    @scalr = Scalr.new({
      :key_id => ENV['SCALR_TEST_API_KEY'], 
      :key_secret => ENV['SCALR_TEST_API_SECRET'], 
      :env_id => ENV['SCALR_TEST_ENV_ID'] 
    })
      
    @dashboard = Dashboard.new @scalr   
  end
  
  def test_get_role_by_name
    role = @dashboard.get_role(ENV['SCALR_TEST_ROLE_NAME'])
    
    assert_not_nil(role, "Test role not found by name")
  end
  
end