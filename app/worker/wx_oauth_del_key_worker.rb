class WxOauthDelKeyWorker
  include Sidekiq::Worker
  sidekiq_options :queue => 'standard', :retry => true, :backtrace => true

  def perform(oauth_state, key)
    $redis.hdel(oauth_state, key)
  end

end