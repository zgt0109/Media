json.array!(@wmall_group_orders) do |order|
  json.id order.id
  json.code order.code
  json.order_no order.order_no
  json.name order.group_item.try(:name)
  json.pic_key order.group_item.pic_key
  #json.mall_name order.try(:group_item).try(:groupable).try(:name)
  json.qty order.qty
  json.total_amount order.total_amount
  json.created_at order.created_at.strftime("%Y-%m-%d %H:%M")
  json.consume_at order.consume_at.strftime("%Y-%m-%d %H:%M")
end