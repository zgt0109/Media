# module ::Guess
#   def self.table_name_prefix
#     'guess_'
#   end
# end

Guess = Module.new do
  def self.table_name_prefix
    'guess_'
  end
end