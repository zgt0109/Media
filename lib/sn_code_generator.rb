class SnCodeGenerator
  def self.generate_code(model,code_field = 'code')
    secret = [*'A'..'Z'].reject{|x| x =~ /I|O/ }.sample(6).join
    new_code = "#{secret}#{rand(10000000...100000000)}"
    code_exists = model.class.where(code_field => new_code).exists?
    code_exists ? generate_code(model,code_field) : new_code
  end
end