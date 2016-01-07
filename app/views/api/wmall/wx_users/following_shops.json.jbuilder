json.wx_user do
  json.id current_wx_user.id
  json.avatar "http://vcl-pictures.qiniucdn.com/avator-d9f534fe5636c7e2ddb49999a5b98fbe.png"
  json.nickname "个人中心"
  json.usable_points "999"
  json.points_url "#nogo"
end

json.shops do
  json.array!(@shops) do |shop|
    json.id shop.id
    json.name shop.name
    json.pic_url shop.pic_url
    json.url mobile_wmall_shop_path(current_user.id, shop.id)
  end
end

