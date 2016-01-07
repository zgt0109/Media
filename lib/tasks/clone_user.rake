#                        被拷贝的用户名,    用户名,       公众号 
# usage rake user:clone[from_user_name,to_user_name]

namespace :user do
  
  desc 'Clone a user'
  task :clone, [:from_user_name, :to_user_name] => :environment do |t, args|
    require "#{__dir__}/../user_cloner"
    puts "*********************************#{args}"
    user_cloner = UserCloner.new(args[:from_user_name])
    user_cloner.clone_to(nickname: args[:to_user_name])
    puts "*********************************cloned=#{user_cloner.cloned}"
    
    File.open("/tmp/user_cloned_#{Time.now.strftime('%F-%H-%M-%S')}", "w") do |io|
      io.puts args
      io.puts user_cloner.cloned
    end
  end

end