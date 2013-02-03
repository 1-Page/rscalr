require 'rscalr'
require 'test/unit'

class TestSig < Test::Unit::TestCase

  def test_generate_timestamp
    scalr = Scalr.new({ :key_id => '123', :key_secret => '123abc' })
    time = Time.new(2013, "feb", 3, 22, 36, 01)
   	timestamp = scalr.generate_timestamp time
   	assert_equal '2013-02-03T22:36:01Z', timestamp
  end

  def test_generate_sig
    scalr = Scalr.new({ :key_id => '123', :key_secret => '123abc' })
    time = Time.new(2013, "feb", 3, 22, 36, 01)
   	timestamp = scalr.generate_timestamp time
    action = 'FarmsList'
   	assert_equal 'XBwijDqKLfCuatAG33SreuL1ftA10L5DZqdTf7mmuII=', scalr.generate_sig(action, timestamp)
  end
  
end