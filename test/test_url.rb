require 'rscalr'
require 'test/unit'

class TestUrl < Test::Unit::TestCase
  
  def test_set_and_get_url
    scalr = Scalr.new({ :key_id => '123', :key_secret => '123abc' })
    
    assert_equal('https://api.scalr.net', scalr.url, "url should default to api.scalr.net if not specified")
    
    scalr = Scalr.new({ :key_id => '123', :key_secret => '123abc', :url => 'https://scalr.example.com/api/api.php' })

    assert_equal('https://scalr.example.com/api/api.php', scalr.url, "url not set correctly from config in ctor")
    
    scalr.url = 'http://api.scalr.example.net'
    
    assert_equal('http://api.scalr.example.net', scalr.url, "url not set correctly from setter")
  end
  
end
