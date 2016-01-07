json.array!(@categories) do |category|
  json.category do
    json.id category.id
    json.name category.name.to_s
    json.url mobile_wmall_shops_path(current_user.id, category: category.name.to_s)
  end

  json.shops do
    json.array!(current_mall.shops.tagged_with(category.name, on: :categories)) do |shop|
      json.id shop.id
      json.name shop.name
      json.pic_url shop.pic_url
      json.url mobile_wmall_shop_path(current_user.id, shop.id)
    end
  end
end
