class GroupItem < ActiveRecord::Base

  acts_as_taggable_on :recommends

  belongs_to :site
  belongs_to :group_category
  belongs_to :group
  belongs_to :groupable, polymorphic: true
  belongs_to :shop, class_name: "Wmall::Shop", foreign_key: 'groupable_id', conditions: "group_items.groupable_type = 'Wmall::Shop'"
  has_many   :group_orders


  has_many :group_comments
  has_many :group_item_pictures

  validates :name, :start_at, :end_at, :coupon_count, :limit_coupon_count,:date_range, presence: true
  validates :price, presence: true, numericality: {greater_than: 0}
  validates :market_price, presence: true, numericality: {greater_than: 0}
  validates :qty, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :group_category_id, presence: true

  scope :latest, -> { order('group_items.created_at DESC') }
  scope :seller_items, lambda{where("start_at < ? and end_at > ?", Time.now, Time.now)}
  scope :on_sale, -> { where('group_items.group_type is null or group_items.group_type = 1') }

  enum_attr :status, :in => [
      ['deleted',  -1,  '已下架'],
      ['selling',     1,  '进行中'],
      ['deal_success', 2,  '已成团'],
      ['deal_failed',  3,  '未成团'],
  ]

  enum_attr :group_type, :in => [
      ['selfgroup',1,'团购'],
      ['wmall', 2, '商圈']
  ]

  attr_accessor :date_range, :picture_keys

  before_validation :set_date_range
  before_save :set_picture_keys
  before_create :add_default_attrs

  accepts_nested_attributes_for :group_item_pictures, allow_destroy: true
  validates_associated :group_item_pictures

  def delete!
    status = self.deleted? ? SELLING : DELETED
    update_attributes!(status: status)
  end

  def pic_url
    if pic_key.present?
      qiniu_image_url(pic_key)
    else
      super
    end
  end

  def out_sell_time
    if end_at < Time.now
      false
    else
      true
    end
  end

  def date_range
    return @date_range if @date_range.present?

    if start_at and end_at
      start_at.to_s << " - " << end_at.to_s
    end
  end

  def set_date_range
    if @date_range.present?
      date_range_list = @date_range.split(" - ")
      self.start_at = Time.parse date_range_list.first
      self.end_at = Time.parse date_range_list.last
    end
  end

  def set_picture_keys(picture_keys = nil)
    picture_keys ||= @picture_keys
    return if picture_keys.nil?

    picture_keys = picture_keys.split(",") if picture_keys.is_a?(String)

    if picture_keys.is_a?(Array)
      _picture_keys = picture_keys.reject{|i| i.blank? or i.eql?("undefined")}
      self.pic_key = _picture_keys.first
      self.group_item_pictures = _picture_keys.map{|key| group_item_pictures.find_or_initialize_by_pic_key(key)}
    end
  end

  def recommend?
    self.recommend_list.include?("recommend")
  end

  def self.get_conditions params
    conn = [[]]
    conn[0] << "group_items.id is not null"
    conn[0] << "wmall_shops.id is not null"
    if params[:shop_id].present?
      conn[0] << "group_items.group_type = 2 and groupable_type = ? and groupable_id = ?"
      conn << "Wmall::Shop"
      conn << params[:shop_id]
    end
    if params[:name].present?
      conn[0] << "(group_items.name like ? or group_items.id like ?)"
      conn << "%#{params[:name]}%"
      conn << "%#{params[:name]}%"
    end
    if params[:mall_name].present?
      conn[0] << "(wmall_shops.name like ? or wmall_shops.id like ?)"
      conn << "%#{params[:mall_name]}%"
      conn << "%#{params[:mall_name]}%"
    end
    conn[0] = conn[0].join(' and ')
    return conn
  end

  private
  def add_default_attrs
    return unless group_category
    self.site_id = group_category.site_id
  end

end
