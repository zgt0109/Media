json.array!(@categories) do |category|
  json.id category.id
  json.level 0
  json.children []
  json.name category.name
  json.position category.position
end
