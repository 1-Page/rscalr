class Role
  attr_accessor :role_id, :name
  
  def to_s
    "{ type: \"role\", role_id: #{@role_id}, name: \"#{@name}\" }"
  end
end