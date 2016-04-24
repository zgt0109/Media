require 'faye'
require 'redis'
require 'active_support/all'
require 'logger'

=begin
$redis = if Rails.env.staging? || Rails.env.production?
  Redis.new(host: '10.221.20.140', port: 6379)
else
  Redis.new(host: 'localhost', port: 6379)
end
=end

# development
Redis.new(host: 'localhost', port: 6379)

# staging or production
#Redis.new(host: '10.221.20.140', port: 6379)

$logger = Logger.new("faye.log")

class ServerAuth
  def incoming(message, callback)
    if message['data']
      if message['data']['shakes']
        site_id = message['data']['shakes'][0]
        shake_round_id = message['data']['shakes'][1]
        shake_user_id = message['data']['shakes'][2]
        $redis.zincrby("shake:user_shake_count:#{site_id}:#{shake_round_id}", 1, shake_user_id)
        message['data']['shakes'][3] = $redis.zscore("shake:user_shake_count:#{site_id}:#{shake_round_id}", shake_user_id)
      end
    end
    callback.call(message)
  rescue => e
    $logger.error e.message
    e.backtrace.each do |error_msg|
      $logger.error error_msg
    end
  end
end

bayeux = Faye::RackAdapter.new(mount: '/faye', timeout: 25)
bayeux.add_extension(ServerAuth.new)
Faye::WebSocket.load_adapter('thin')
run bayeux
