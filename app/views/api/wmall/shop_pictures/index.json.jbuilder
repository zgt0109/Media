json.pictures do
  json.array!(@pictures) do |picture|
    json.pic_url picture.pic_url
    json.name picture.name.to_s
  end
end
