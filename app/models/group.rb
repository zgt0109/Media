class Group < ActiveRecord::Base

  belongs_to :site
  belongs_to :wx_mp_user

  has_one :activity, as: :activityable
  has_many :group_items, :dependent => :destroy
  has_many :group_categories, :dependent => :destroy, :order => 'sort ASC'



  validates :name, presence: true, length: { maximum: 64, message: '名称过长' }
  #validates :tel, presence: true, on: :update

  accepts_nested_attributes_for :activity

  def clear_menus!
    supplier.group_categories.clear
  end

  def get_category params
    conn = []
    if params[:category_id].present?
      conn << "group_category_id = ? "
      conn << params[:category_id]
    end
    return conn
  end

  def get_items_conditions params
    conn = [[]]
    conn[0] << "group_items.group_type is null or group_items.group_type = 1"
    if params[:name].present?
      conn[0] << "group_items.name like ?"
      conn << "%#{params[:name].strip}%"

      conn[0] << "group_categories.name like ?"
      conn << "%#{params[:name].strip}%"
    end
    conn[0] = conn[0].join(' or ')
    conn
  end

  # traversal all category and return to hash
  # :key [:symbol] every node key was node.send(key)
  # :fields [:array] every node value
  # for node have children will traversal all children node to :children_list
  # :proc if block_given? exec proc.call(children_list)
  # else will wrappen node's child list to {children: children_list}
  # usage:
  # tree_hash = GroupCategory.tree_data(:name, [:name, :id]) do |children_tree|
  #   _children_tree = Hash[children_tree.map{|key, value| [key, value.reverse_merge(type: "item")]}]
  #  {additionalParameters: {children: _children_tree}}
  # end
  def category_tree_data(key = :id ,fields = [:id, :name], &proc)
    tree_hash = {}
    group_categories.root.each do |child|
      if block_given?
        _tree_hash = GroupCategory.children_tree_data(child, key, fields, &proc)
      else
        _tree_hash = GroupCategory.children_tree_data(child, key, fields)
      end

      tree_hash.merge!(_tree_hash) if _tree_hash.present?
    end

    tree_hash
  end

end
