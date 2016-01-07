json.array!(@activities) do |it|
  json.id it.id
  json.pic_url it.pic_url
  json.name it.name.to_s
  json.description it.description.to_s
  json.category (it.category_list & ['banner','common']).first
  json.url "#nogo"
end
