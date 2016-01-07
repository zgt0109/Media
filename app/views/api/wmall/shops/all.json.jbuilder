json.aaData do
  json.array!(@shops) do |shop|
    json.array! [shop.id, shop.name, shop.sn.to_s, shop.pic_url, "keywords", shop.category_list.join(","), "false"]
  end
end
