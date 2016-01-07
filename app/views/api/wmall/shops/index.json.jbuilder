json.array!(@shops) do |it|
  json.id it.id
  json.pic_url it.pic_url
  json.name it.name.to_s
  json.url "#nogo"
end
