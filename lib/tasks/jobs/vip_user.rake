namespace :vip_user do

  desc "Upgrade vip_users by time"
  task :upgrade_by_time => :environment do
    suppliers = Supplier.joins(:vip_card).where("vip_cards.id IN (SELECT vip_card_id from vip_grades where category=1)")
    suppliers.find_each do |supplier|
      supplier.vip_users.find_each do |vip_user|
        vip_user.upgrade_by_time
      end
    end
  end

end
