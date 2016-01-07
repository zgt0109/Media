require 'uri'

namespace :alipay do
  task :direct => :environment do
    payment = Payment.last

    puts payment.get_request_token
  end
end
