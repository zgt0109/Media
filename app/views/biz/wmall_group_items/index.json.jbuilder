json.array!(@wmall_group_items) do |item|
  json.id item.id
  json.name item.name
  json.package_description strip_tags item.summary
  json.price item.price
  json.market_price item.market_price
  json.seller_count item.group_orders.count
  json.pic_key item.pic_key
end