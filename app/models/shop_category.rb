class ShopCategory < ActiveRecord::Base
  enum_attr :status, :in => [
    ['deleted', -1, '已删除'],
    ['normal', 1, '正常']
  ]

  belongs_to :site
  belongs_to :shop
  belongs_to :shop_branch
  belongs_to :shop_menu
  has_many :shop_products, class_name: "ShopProduct", foreign_key: :category_parent_id
  has_many :children_products, class_name: "ShopProduct", foreign_key: :shop_category_id

  belongs_to :parent, class_name: 'ShopCategory', foreign_key: :parent_id
  has_many :children, class_name: 'ShopCategory', foreign_key: :parent_id, :dependent => :destroy

  scope :without_children, includes(:children).where(:children => { :id => nil })
  scope :second_scope, where("parent_id <> 0")
  scope :visitable, :include => [:shop_products], :conditions => "shop_products.id IS NOT NULL"
  scope :root, ->{where(parent_id: 0)}

  default_scope { order(:sort) }

  before_create :add_default_attrs
  after_save :move_parent_shop_products

  def is_root
    self.parent_id == 0
  end

  def can_delete?
    shop_products.count == 0
  end

  def delete!
    if shop_products.count > 0
      update_attributes(status: DELETED)
    else
      destroy
    end
  end

  def has_children?
    children.count > 0
  end

  def update_sort_up sort_value
    if self.is_root
      same_sort_categories = self.shop_menu.shop_categories.root.where(sort: sort_value)
    else
      same_sort_categories = self.parent.children.where(sort: sort_value)
    end

    same_sort_categories.each do |p|
      p.update_sort_up(p.sort + 1) unless p.id == self.id
    end
    self.update_column("sort", sort_value)
  end

  def update_sort_down sort_value
    if self.is_root
      same_sort_categories = self.shop_menu.shop_categories.root.where(sort: sort_value)
    else
      same_sort_categories = self.parent.children.where(sort: sort_value)
    end

    same_sort_categories.each do |p|
      p.update_sort_down(p.sort - 1) unless p.id == self.id
    end
    self.update_column("sort", sort_value)
  end

  def sort_products
    ret = Array.new
    top = self.shop_products.where(:is_category_top => true).first
    ret << top if top
    self.shop_products.order('sort asc').each do |p|
      ret << p unless p.is_category_top
    end

    ret
  end

  def resort
    if self.is_root
      same_sort_categories = self.shop_menu.shop_categories.root
    else
      same_sort_categories = self.parent.children
    end
    
    same_sort_categories.order("sort").each_with_index do |c, index|
      c.update_column("sort", index)
    end
  end

  private

  def add_default_attrs
    return unless self.shop

    self.site_id = self.shop.site_id
    self.shop_id = self.shop.id
  end

  # 如果一个子分类是其父级分类的第一个子分类, 那么原本所有属于
  # 父级分类下的菜品都会被放入这个子分类中
  def move_parent_shop_products
    if self.is_root
    elsif self.parent.children.count == 1 && self.parent.children.first.id == self.id
      self.parent.shop_products.each do |product|
        product.update_column("shop_category_id", self.id)
      end
    end
  end

end
