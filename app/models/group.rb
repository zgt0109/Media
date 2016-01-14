class Group < ActiveRecord::Base

  belongs_to :site

  has_one :activity, as: :activityable
  has_many :group_items, :dependent => :destroy
  has_many :group_categories, :dependent => :destroy, :order => 'sort ASC'

  validates :name, presence: true, length: { maximum: 64, message: '名称过长' }

  accepts_nested_attributes_for :activity

  def clear_menus!
    site.group_categories.clear
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
