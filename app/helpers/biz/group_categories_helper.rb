module Biz::GroupCategoriesHelper
  # FIXME parse json with order at frontend, so should return note as array list
  def generate_category_tree_data(group)
    tree_hash = group.category_tree_data(:id, [:name, :id, :sort]) do |children_tree|

      _children_tree =children_tree.collect do |key, value|
        _type = value.has_key?("children") ? "folder": "item"
        value.reverse_merge(type: _type)
      end
      {children: _children_tree}
      # _children_tree = children_tree.collect{|key, value| {key => value.reverse_merge(type: "item")}}
      #_children_tree = Hash[children_tree.map{|key, value| [key, value.reverse_merge(type: "item")]}]

      #{additionalParameters: {children: _children_tree}}
    end

    _tree_hash = HashWithIndifferentAccess.new()
    #_tree_list = []

    tree_hash.each do |key, value|
      if value.has_key?("children")
        value.reverse_merge!(type: "folder")
      else
        value.reverse_merge!(type: "item")
      end

       _tree_hash[key] = value
      #_tree_list << {key => value}
    end

    JSON.pretty_generate _tree_hash.values
    #JSON.pretty_generate _tree_list
  end

  def category_tree_data(group)
    generate_category_tree_data(group)
  end

  def time_7_days_ago
    t = (Time.now - 6.days)
    Time.new(t.year, t.mon, t.day)
  end

  def a_months_ago
    t = (Time.now - 29.days)
    Time.new(t.year, t.mon, t.day)
  end
end
