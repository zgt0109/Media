json.category do
  json.name @category_name
end

json.shops do
  json.array!(@shops) do |shop|
    json.id shop.id
    json.name shop.name
    json.pic_url shop.pic_url
    json.url "#nogo"
  end
end
