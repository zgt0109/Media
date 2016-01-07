desc 'data cleanup'
task :data_cleanup => :environment do
  # website_supplier_ids = []
  # Website.micro_site.where(supplier_id: %w()).order('id').each do |website|
  #   if website_supplier_ids.include?(website.supplier_id)
  #     puts "will delete website id #{website.id} for supplier_id: #{website.supplier_id}"
  #     website.destroy
  #   else
  #     website_supplier_ids << website.supplier_id
  #   end
  # end

  #
  # supplier_ids = []
  # Shop.where(supplier_id: %w[]).order('id').each do |shop|
  #   if supplier_ids.include?(shop.supplier_id)
  #     puts "will delete shop id #{shop.id} for supplier_id: #{shop.supplier_id}"
  #     # shop.destroy
  #   else
  #     supplier_ids << shop.supplier_id
  #   end
  # end
  #
  # vip_card_supplier_ids = []
  # VipCard.where(supplier_id: %w[10832 11035 11152 11218 11256 11266 11276]).order('id').each do |vip_card|
  #   if vip_card_supplier_ids.include?(vip_card.supplier_id)
  #     puts "will delete vip_card id #{vip_card.id} for supplier_id: #{vip_card.supplier_id}"
  #     vip_card.destroy
  #   else
  #     vip_card_supplier_ids << vip_card.supplier_id
  #   end
  # end
  #
  # ActivityNotice.find_each do |activity_notice|
  #   unless activity_notice.activity
  #     puts "will delete activity_notice id #{activity_notice.id} for activity_id: #{activity_notice.activity_id}"
  #     activity_notice.destroy
  #   end
  # end
  activity_supplier_ids = []
  Activity.where(activity_type_id: 13, supplier_id: %w()).order('id').each do |activity|
    if activity_supplier_ids.include?(activity.supplier_id)
      puts "will delete activity id #{activity.id} for supplier_id: #{activity.supplier_id}"
      activity.destroy
    else
      activity_supplier_ids << activity.supplier_id
    end
  end
end
