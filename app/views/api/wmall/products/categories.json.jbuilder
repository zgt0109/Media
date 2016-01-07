json.array!(@categories) do |it|
  json.id it.id
  json.name it.name.to_s
  json.count it.taggings_count
  json.url mobile_wmall_products_path(current_user.id, category: it.name)
end
