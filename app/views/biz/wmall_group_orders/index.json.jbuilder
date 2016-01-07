json.array!(@wmall_group_orders) do |order|
  json.id order.id
  json.order_no order.order_no
  json.trade_no order.payments.success.try(:first).try(:trade_no)
  json.payment_type order.try(:payment_type).try(:name)
  json.code order.code
  json.name order.group_item.try(:name)
  json.mall_name order.try(:group_item).try(:groupable).try(:name)
  json.total_amount order.total_amount
  json.status order.status
  json.created_at order.created_at.strftime("%Y-%m-%d %H:%M")
end