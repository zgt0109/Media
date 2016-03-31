# -*- encoding : utf-8 -*-
# 短信订单相关任务
namespace :sms_order do

  desc '每月1日凌晨重置赠送短信套餐'
  task :reset_free_sms_every_month => :environment do
    begin
      SmsOrder.reset_free_sms_every_month
      puts "重置赠送短信套餐成功！"
    rescue Exception => e
      puts "重置赠送短信套餐失败：#{e}"
    end
  end

end
