if @group_order.present?
    json.id @group_order.id
    json.order_no @group_order.order_no
    json.code @group_order.code
    json.item_name @group_order.group_item.name
    json.qty @group_order.qty
    json.total_amount @group_order.total_amount
    json.created_at @group_order.created_at.strftime("%Y-%m-%d %H:%M")
    json.username @group_order.username
    json.mobile @group_order.mobile
    json.status @group_order.status
    json.status_name @group_order.status_name
end
