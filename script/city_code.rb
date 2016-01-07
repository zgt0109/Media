content = File.read('code.txt')
#p content

citys = content.split('|')
citys.each do |c|
  puts c
end
