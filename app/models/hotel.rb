class Hotel < ActiveRecord::Base
  validates :name, :obligate_time, :cancel_time, presence: true
  
  belongs_to :site

  has_many :hotel_branches, dependent: :destroy
  has_many :hotel_room_types, dependent: :destroy
  has_many :hotel_room_settings, dependent: :destroy
  has_many :hotel_pictures, dependent: :destroy
  has_many :hotel_comments, dependent: :destroy
  has_many :hotel_orders, dependent: :destroy

  has_one :activity, as: :activityable, order: :activity_type_id, dependent: :destroy

  accepts_nested_attributes_for :activity
end
