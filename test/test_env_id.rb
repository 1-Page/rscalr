require 'rscalr'
require 'test/unit'

class TestSig < Test::Unit::TestCase
  
  def test_set_and_get_env
    scalr = Scalr.new({ :key_id => '123', :key_secret => '123abc' })
    
    assert_equal(nil, scalr.env_id, "env_id should default to nil if not specified")
    
    scalr = Scalr.new({ :key_id => '123', :key_secret => '123abc', :env_id => 456 })

    assert_equal(456, scalr.env_id, "env_id not set correctly from config in ctor")
    
    scalr.env_id = 789
    
    assert_equal(789, scalr.env_id, "env_id not set correctly from setter")
  end
  
end