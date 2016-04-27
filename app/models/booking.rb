class Booking < ActiveRecord::Base
  store :metadata, accessors: [:notify_merchant_mobiles, :is_open_booking]

  validates :name, presence: true, length: { maximum: 64, message: '名称过长' }
  # validates :tel, presence: true

  belongs_to :site
  has_one :activity, as: :activityable, dependent: :destroy
  has_many :booking_orders
  has_many :booking_categories
  has_many :booking_items
  has_many :booking_ads

  accepts_nested_attributes_for :activity

  default_scope -> { order('created_at desc') }
  enum_attr :booking_type, :in => [
    ['deliver',1,'快递服务'],
    ['rent',2,'租赁服务'],
    ['driving',3,'驾校服务'],
    ['clean',4,'保洁服务'],
    ['moving',5,'搬家服务']
  ]

  def clear_menus!
    booking_categories.clear
  end

  def multilevel_menu params
    booking_categories, booking_categories_selects = self.booking_categories.root.order(:sort), []
    index = 1
    booking_categories_selects.push([index, booking_categories])
    return booking_categories_selects if params["booking_category_id#{index}".to_sym].to_i <= 0 && params[:action] == 'index'
    if params["booking_category_id#{index}".to_sym].present?
      booking_categories.where(id: params["booking_category_id#{index}".to_sym].to_i).first.try(:multilevel_menu_down, index + 1, params, booking_categories_selects)
    else
      booking_categories.first.try(:multilevel_menu_down, index + 1, params, booking_categories_selects)
    end
    booking_categories_selects
  end

  def show_items params
    items = []
    booking_categories.root.each do |category|
      if category.has_children?
        if category.id == params[:booking_category_id].to_i
          items << category.booking_items.normal
          category.items params, items, true
        else
          category.items params, items
        end
      else
        next unless category.id == params[:booking_category_id].to_i
        items << category.booking_items.normal
      end
    end if params[:booking_category_id].present?

    items = booking_items.normal unless params[:booking_category_id].present?
    items = items.flatten
    items = items.select{|item| item.id == params[:id].to_i} if params[:id].present?
    items = items.select{|item| item.name =~ /.*(#{params[:name].strip()}).*/} if params[:name].present?
    items.flatten.sort{|x, y| y.created_at <=> x.created_at }
  end
end
