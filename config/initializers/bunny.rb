# if defined? Bunny
#   RABBITMQ_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/rabbitmq.yml")[Rails.env] || {})
#   $rabbitmq = Bunny.new RABBITMQ_CONFIG


#   $rabbitmq_lazy = -> (&proc) {
#     $rabbitmq.start

#     proc.call($rabbitmq)

#     $rabbitmq.close
#   }

#   def send_mq_message(queue_name="default")
#     if block_given?
#       Timeout::timeout(30) do
#         $rabbitmq.start
#         channel = $rabbitmq.create_channel
#         queue = channel.queue(queue_name)
#         yield queue
#       end 
#     end 
#   rescue => e
#     puts e.message
#     nil 
#   ensure
#     $rabbitmq.close
#   end
# end

