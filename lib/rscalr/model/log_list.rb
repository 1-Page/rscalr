class LogList
  attr_accessor :total_records, :start, :limit
  attr_reader :logs
  
  def initialize
    @logs = []
  end
  
  def <<(log)
    @logs << log if log.is_a? Log
  end
  
  def to_s
    "{ type: \"loglist\", total_records: #{@total_records}, start: \"#{@message}\", limit: #{@severity}, logs: [ #{@logs.each do |log| log.to_s + ',' end} ] }"
  end
end