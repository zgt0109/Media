# == Schema Information
#
# Table name: hotels
#
#  id            :integer          not null, primary key
#  supplier_id   :integer          not null
#  wx_mp_user_id :integer          not null
#  name          :string(255)      not null
#  status        :integer          default(1), not null
#  obligate_time :string(255)      not null
#  cancel_time   :string(255)      not null
#  description   :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Hotel < ActiveRecord::Base
#  attr_accessible :cancel_time, :description, :name, :obligate_time, :status, :supplier_id, :wx_mp_user_id
  validates :name, :obligate_time, :cancel_time, presence: true
  
  belongs_to :supplier
  belongs_to :wx_mp_user

  has_many :hotel_branches, dependent: :destroy
  has_many :hotel_room_types, dependent: :destroy
  has_many :hotel_room_settings, dependent: :destroy
  has_many :hotel_pictures, dependent: :destroy
  has_many :hotel_comments, dependent: :destroy
  has_many :hotel_orders, dependent: :destroy

  has_one :activity, as: :activityable, order: :activity_type_id, dependent: :destroy

  accepts_nested_attributes_for :activity
end
