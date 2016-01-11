class GroupCategory < ActiveRecord::Base
  belongs_to :site

  belongs_to :parent, class_name: 'GroupCategory', foreign_key: :parent_id
  has_many :children, class_name: 'GroupCategory', foreign_key: :parent_id, :order => 'sort ASC'
  has_many :group_items
  belongs_to :group

  acts_as_list scope: :group, column: "sort"
  acts_as_tree order: "sort", foreign_key: :parent_id, counter_cache: false

  validates :name, presence: true, length: { maximum: 64, message: '不能超过64个字' }
  validates :sort, presence: true
  validates :sort, numericality: { only_integer: true, greater_than: 0 }

  before_create :add_default_attrs

  scope :root, -> { where(parent_id: 0) }

  scope :unroot, -> { where("parent_id <> 0 and parent_id is not null") }

  def has_children?
    children.count > 0
  end

  def leaf?
    ! children.exists?
  end

  def parent?
    parent_cid == 0
  end

  def com_str str = [], first_name = nil
    if parent
      str.unshift parent.name
      parent.com_str str, first_name
    else
      str.unshift first_name if first_name
      str.join(" > ")
    end
  end

  def allow_menu_layer sum = 1
    if parent
      parent.allow_menu_layer sum + 1
    else
      sum <= 2
    end
  end


  class << self
    # :key [:symbol] every node key was node.send(key)
    # :fields [:array] every node value
    # :proc if block_given? exec proc.call(children_list)
    # else will wrappen node's child list to {children: children_list}
    def children_tree_data(child, key = :id, fields = [:id ,:name], &proc)
      tree_hash = HashWithIndifferentAccess.new({})
      fields = fields.map(&:to_s)
      key_val = child.send(key)

      _tree_hash = {key_val => child.attributes.select{|k,_| fields.include?("#{k}")} }

      unless child.leaf?
        children_tree = HashWithIndifferentAccess.new({})
        child.children.each do |_child|
          _children_tree = children_tree_data(_child, key, fields, &proc)
          children_tree.merge! _children_tree
        end

        if block_given?
          _tree_hash[key_val].merge! proc.call(children_tree)
        else
          _tree_hash[key_val][:children] = children_tree
        end

      end

      tree_hash.merge! _tree_hash
    end
  end

  private

  def add_default_attrs
    return unless self.group
    self.site_id = self.group.site_id
  end
end
