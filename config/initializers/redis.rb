if Rails.env.staging? || Rails.env.production?
  $redis = Redis.new(host: 'localhost', port: 6379)
else
  $redis = Redis.new(host: 'localhost', port: 6379)
end