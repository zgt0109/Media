# -*- encoding : utf-8 -*-
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every 30.minutes do
  rake "timer:shop_order_expire"
  rake "timer:vote"
end

# every 1.days, :at => '00:01 am' do
#   rake "hotel:hotel_room_settings"
# end

every 1.days, :at => '00:03 am' do
  rake "hospital:expired_hospital_doctor_arrange_items"
end

every 1.days, :at => '00:05 am' do
  rake "hospital:create_doctor_watches"
end

every '7 0 1 * *' do
  # 每月1日凌晨重置赠送短信套餐
  rake "sms_order:reset_free_sms_every_month"
end

# every 1.days, :at => '00:08 am' do
#   rake "shop:shop_table_settings"
# end

every 1.days, :at => '00:15 am' do
  rake "timer:hospital_order_expire"
end

every 1.days, :at => '02:07 am' do
  # VIP用户每天凌晨2点自动升级会员等级（仅限按使用时间的等级）
  rake "vip_user:upgrade_by_time"
end

every 1.days, :at => '08:31 am' do
  #更新微信接口数据
  rake "wx_stats:all"
end
