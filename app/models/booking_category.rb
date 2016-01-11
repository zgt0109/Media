class BookingCategory < ActiveRecord::Base
  belongs_to :site

  belongs_to :parent, class_name: 'BookingCategory', foreign_key: :parent_id
  has_many :children, class_name: 'BookingCategory', foreign_key: :parent_id
  has_many :booking_items

  validates :name, presence: true, length: { maximum: 64, message: '不能超过64个字' }
  validates :sort, presence: true
  validates :sort, numericality: { only_integer: true, greater_than: 0}

  before_create :add_default_attrs
  after_create :update_items_booking_category_id

  scope :root, -> { where(parent_id: 0) }

  def show_products
    if self.has_children?
      seller_ids = (self.children.map(&:cid) << self.cid)#.join(",")
      return products = EcItem.where("seller_cid in (?) and ec_shop_id = ?",seller_ids, self.ec_shop_id ).order("created_at desc")
    else
      products = self.ec_items.where("service_id = ?",self.service_id).order("created_at desc")
    end
    return products
  end

  def products items = []
    items << booking_items #unless has_children?
    children.each do |child|
      #items << child.booking_items #unless has_children?
      child.products items if has_children?
    end if has_children?
    items.flatten.sort{|x, y| y.created_at <=> x.created_at }
  end

  def has_children?
    children.count > 0
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

  def allow_menu_layer sum = 1, is_counter = false
    if parent
      parent.allow_menu_layer sum + 1, is_counter
    else
      is_counter ? sum : sum <= 2
    end
  end

  def multilevel_menu_down index, params, booking_categories_selects
    #return unless params["booking_category_id#{index - 1}".to_sym].to_i <= 1
    if has_children? && allow_menu_layer
      categories = children.order(:sort)
      booking_categories_selects.push([index, categories])
      return if params["booking_category_id#{index}".to_sym].to_i <= 0 && params[:action] == 'index'
      if params["booking_category_id#{index}".to_sym].present?
        categories.where(id: params["booking_category_id#{index}".to_sym].to_i).first.try(:multilevel_menu_down, index + 1, params, booking_categories_selects)
      else
        categories.first.try(:multilevel_menu_down, index + 1, params, booking_categories_selects)
      end
    end
  end

  def multilevel_menu_up index, params, booking_categories_selects
    return unless supplier
    return unless parent_id
    params["booking_category_id#{index}".to_sym] = id
    if parent_id == 0
      booking_categories_selects.unshift([index, supplier.booking_categories.root.order(:sort)])
    else
      booking_categories_selects.unshift([index, parent.children.order(:sort)])
      parent.try(:multilevel_menu_up, index - 1, params, booking_categories_selects)
    end
  end

  def items params, items, is_a = false
    children.each do |child|
      if child.has_children?
        if is_a
          items << child.booking_items
          child.items params, items, is_a
        else
          if child.id == params[:booking_category_id].to_i
            items << child.booking_items
            child.items params, items, true
          else
            child.items params, items
          end
        end
      else
        if is_a
          items << child.booking_items
        else
          next unless child.id == params[:booking_category_id].to_i
          items << child.booking_items
        end
      end
    end
  end


  def update_items_booking_category_id
    parent.booking_items.update_all(booking_category_id: id) if parent && parent.try(:children).count == 1
  end

  private

  def add_default_attrs
    if self.parent
      self.sort = self.parent.children.order(:sort).try(:last).try(:sort).to_i + 1
    else
      self.sort = supplier.booking_categories.root.order(:sort).try(:last).try(:sort).to_i + 1
    end
  end

end