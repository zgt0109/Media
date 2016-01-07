json.name @shop.name
json.card_pic_url "http://weixin.qiniucdn.com/e85f153b-c092-4e4e-aae4-e9178bbd31a6-large"
json.phone @shop.phone
json.card_number "000to be done using current wx user"
json.follow_status current_wx_user.following?(@shop)

json.activities do
  json.array!(@activities) do |activity|
    json.name nil #activity.name
    json.description activity.description
  end
end

json.description @shop.description
json.address @shop.address

