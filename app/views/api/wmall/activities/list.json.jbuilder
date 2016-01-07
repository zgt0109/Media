json.array!(@activities) do |it|
  json.id it.id
  json.pic_url it.pic_url
  json.name it.name.to_s
  json.description it.description.to_s
  json.category (it.category_list & ['banner','common']).first
  json.url "#nogo"
  json.start_date it.start_datetime.present? ? it.start_datetime.strftime("%Y-%m-%d") : ""
  json.end_date it.end_datetime.present? ? it.end_datetime.strftime("%Y-%m-%d") : ""
end
