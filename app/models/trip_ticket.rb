class TripTicket < ActiveRecord::Base
  mount_uploader :pic, TripTicketUploader
  img_is_exist({pic: :pic_key})

  validates :name, :price, presence: true

  scope :visible, -> { where("status != -2") }
  scope :latest,  -> { order('id desc') }

  belongs_to :trip
  has_many :trip_orders
  belongs_to :trip_ticket_category

  enum_attr :status, :in => [
    ['online', 1, '上架'],
    ['offline', -1, '下架'],
    ['deleted', -2, '已删除']
  ]

  def status_will_be
    status.eql?(1) ? -1 : 1
  end

  def status_name_will_be
    TripTicket::STATUSES.send("[]", status_will_be)
  end

  def pic_url
    if pic_key.present?
      qiniu_image_url(pic_key)
    else
      super
    end
  end

  def self.categorized(category = nil)
    if category
      joins(:trip_ticket_category).where("trip_ticket_categories.id" => category.self_and_descendants.to_a.map(&:id)).uniq
    else
      includes(:trip_ticket_category)
    end
  end

end
