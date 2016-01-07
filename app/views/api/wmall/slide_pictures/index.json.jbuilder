json.array!(@slide_pictures) do |it|
  json.pic_url it.pic_url
  json.link_value it.link_value || "#nogo"
end
