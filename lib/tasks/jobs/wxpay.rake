require 'uri'

namespace :wxpay do

  task :delivery => :environment do
    Payment.wxpay.success.where(is_delivery: false).each do |payment|
      puts "payment #{payment.id} is starting delivery"

      payment.wxpay_delivery
    end
  end

end
