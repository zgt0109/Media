# == Schema Information
#
# Table name: hotel_room_types
#
#  id              :integer          not null, primary key
#  hotel_id        :integer          not null
#  hotel_branch_id :integer          not null
#  name            :string(255)      not null
#  price           :integer          not null
#  discount_price  :integer          not null
#  open_qty        :integer          default(0)
#  pic             :string(255)      not null
#  status          :integer          default(1), not null
#  is_breakfast    :boolean
#  is_broadband    :boolean
#  area            :integer
#  floor           :string(255)
#  is_big_bed      :boolean
#  big_bed_spec    :string(255)
#  big_bed_count   :integer
#  is_small_bed    :boolean
#  small_bed_spec  :string(255)
#  small_bed_count :integer
#  description     :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class HotelRoomType < ActiveRecord::Base
  #attr_accessible :area, :big_bed_count, :big_bed_spec, :description, :floor, :hotel_branch_id, :hotel_id, :is_big_bed, :is_breakfast, :is_broadband, :is_small_bed, :name, :open_count, :pic, :preferential_price, :price, :small_bed_count, :small_bed_spec, :status
  attr_accessor :has_defaults

  mount_uploader :pic, HotelRoomTypeUploader
  img_is_exist({pic: :qiniu_pic_key})

  validates :hotel_branch_id, :name, presence: true
  #validates :pic, presence: true, on: :create
  validates_numericality_of  :open_qty, greater_than_or_equal_to: 0, presence: true, only_integer: true
  validates_numericality_of  :price, greater_than_or_equal_to: 0, presence: true
  validates_numericality_of  :discount_price, greater_than_or_equal_to: 0, allow_blank: true

  #validates_numericality_of  :floor, greater_than_or_equal_to: 0, only_integer: true, allow_blank: true
  #validates_numericality_of  :big_bed_count, greater_than_or_equal_to: 0, only_integer: true, allow_blank: true
  #validates_numericality_of  :small_bed_count, greater_than_or_equal_to: 0, only_integer: true, allow_blank: true

  belongs_to :hotel_branch
  has_many :hotel_orders, dependent: :destroy
  has_many :hotel_room_settings, dependent: :destroy

  after_create :create_default_room_settings

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除']
  ]

  enum_attr :is_breakfast, :in => [
    ['has_breakfast', 1, '有早'],
    ['no_breakfast', 0, '无早']
  ]

  enum_attr :is_broadband, :in => [
    ['has_broadband', 1, '有宽带'],
    ['no_broadband', 0, '无宽带']
  ]


  def pic_url(type = :large)
    qiniu_image_url(qiniu_pic_key) || pic.try(type)
  end

	def delete!
		update_attributes(status: DELETED) if normal?
	end

  def create_default_room_settings
    (Date.today .. Date.today+31.days).each do |date|
      attrs = {
        hotel_id: hotel_id,
        hotel_branch_id: hotel_branch_id,
        hotel_room_type_id: id,
        date: date,
        open_qty: open_qty,
        booked_qty: 0,
        available_qty: open_qty
      }
      hotel_room_settings.where(hotel_room_type_id: id,date: date).first_or_create(attrs)
    end unless has_defaults
  end

  def room_price
    if discount_price.to_f > 0
      discount_price
    else
      price
    end
  end

  def create_hotel_room_settings(date)
    puts "date #{date} hotel_branch_id #{self.hotel_branch_id}"
    attrs = {
      hotel_id: self.hotel_id,
      hotel_branch_id: self.hotel_branch_id,
      hotel_room_type_id: self.id,
      date: date,
      open_qty: self.open_qty,
      booked_qty: 0,
      available_qty: self.open_qty
    }
    self.hotel_room_settings.where(hotel_room_type_id: self.id,date: date).first_or_create!(attrs)
  end

end
