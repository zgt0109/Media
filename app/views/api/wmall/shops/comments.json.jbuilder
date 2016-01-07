json.shop do
  json.id @shop.id
  json.name @shop.name
  json.pic_url @shop.pic_url
  json.url mobile_wmall_shop_path(current_user.id, @shop.id)
end

json.comments do
  json.array!(@comments) do |comment|
    json.id comment.id
    json.nickname comment.nickname.to_s
    json.rank comment.rank
    json.average_spend comment.average_spend
    json.content comment.content
  end
end
