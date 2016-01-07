json.activities do
  json.array!(@activities) do |activity|
    json.name activity.name.to_s
  end
end
