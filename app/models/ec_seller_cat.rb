class EcSellerCat < ActiveRecord::Base
  # attr_accessible :cid, :name, :parent_cid, :parent_id, :pic_url, :sort_order, :type

  validates :name, presence: true, length: { maximum: 64, message: '不能超过64个字' }
  validates :sort_order, presence: true
  validates :sort_order, numericality: { only_integer: true}
  validates :pic_url, format: { with: /^(http|https):\/\/[a-zA-Z0-9].+$/, message: '地址格式不正确，必须以http(s)://开头' }, allow_blank: true

  belongs_to :site
  belongs_to :ec_shop
  belongs_to :parent, class_name: 'EcSellerCat', foreign_key: :parent_cid, primary_key: :cid
  has_many :children, class_name: 'EcSellerCat', foreign_key: :parent_cid, primary_key: :cid, dependent: :destroy
  has_many :ec_items, primary_key: :cid, foreign_key: :seller_cid, dependent: :destroy

  before_create :add_default_attrs
  after_save :update_cat_ids
  after_create :update_items_seller_cid

  scope :root, -> { where(parent_cid: 0) }

  enum_attr :status, :in => [
    ['deleted',  '已删除'],
    ['normal',  '正常']
  ]

  def delete!
    update_column('status', 'deleted')
    items = products [], true
    if items.count > 0
      items.each{|item| item.update_column('status', EcItem::DELETED)}
    end
  end

  def show_products
    if self.has_children?
      seller_ids = (self.children.map(&:cid) << self.cid)#.join(",")
      return products = EcItem.where("seller_cid in (?) and ec_shop_id = ?",seller_ids, self.ec_shop_id ).order("created_at desc")
    else
      products = self.ec_items.where("ec_shop_id = ?",self.ec_shop_id).order("created_at desc")
    end
    return products
  end

  def has_children?
    children.count > 0
  end

  def parent?
    parent_cid == 0
  end

  def products items = [], is_all = false
    items << (is_all ? ec_items : ec_items.selling) #unless has_children?

    cats =  is_all ? children : children.normal

    cats.each do |child|
      child.products items, is_all if has_children?
    end

    items.flatten.sort{|x, y| y.created_at <=> x.created_at }
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

  def allow_menu_layer sum = 1, is_counter = false
    if parent
      parent.allow_menu_layer sum + 1, is_counter
    else
      is_counter ? sum : sum <= 2
    end
  end

  def multilevel_menu_down index, params, ec_seller_cat_selects
    if has_children? && allow_menu_layer
      categories = children.normal.order(:sort_order)
      ec_seller_cat_selects.push([index, categories])
      return if params["ec_seller_cat_id#{index}".to_sym].to_i <= 0 && params[:action] == 'index'
      if params["ec_seller_cat_id#{index}".to_sym].present?
        categories.where(id: params["ec_seller_cat_id#{index}".to_sym].to_i).first.try(:multilevel_menu_down, index + 1, params, ec_seller_cat_selects)
      else
        categories.first.try(:multilevel_menu_down, index + 1, params, ec_seller_cat_selects)
      end
    end
  end

  def multilevel_menu_up index, params, ec_seller_cat_selects
    return unless site
    return unless parent_id
    params["ec_seller_cat_id#{index}".to_sym] = id
    if parent_id == 0
      ec_seller_cat_selects.unshift([index, ec_shop.categories.normal.root.order(:sort_order)])
    else
      ec_seller_cat_selects.unshift([index, parent.children.normal.order(:sort_order)])
      parent.try(:multilevel_menu_up, index - 1, params, ec_seller_cat_selects)
    end
  end

  def items params, items, is_a = false
    children.each do |child|
      if child.has_children?
        if is_a
          items << child.ec_items
          child.items params, items, is_a
        else
          if child.id == params[:ec_seller_cat_id].to_i
            items << child.ec_items
            child.items params, items, true
          else
            child.items params, items
          end
        end
      else
        if is_a
          items << child.ec_items
        else
          next unless child.id == params[:ec_seller_cat_id].to_i
          items << child.ec_items
        end
      end
    end
  end

  # TODO
  def update_cat_ids
    update_attributes(cid: id, parent_cid: parent_id) unless cid
  end

  def update_items_seller_cid
    parent.ec_items.update_all(seller_cid: id) if parent && parent.try(:children).count == 1
  end

  private

  def add_default_attrs
    return unless ec_shop
    self.site_id = ec_shop.site_id
  end

end
