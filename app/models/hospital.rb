class Hospital < ActiveRecord::Base
  belongs_to :site

  has_one :activity, as: :activityable
  has_many :hospital_departments
  has_many :hospital_orders
  has_many :hospital_job_titles
  has_many :hospital_doctors
  has_many :hospital_comments
  has_many :doctor_arranges, through: :hospital_doctors
  has_many :doctor_watches,  through: :hospital_doctors
  has_many :doctor_arrange_items, through: :doctor_watches
  accepts_nested_attributes_for :activity

  validates :name, presence: true, length: { maximum: 64 }

  def clear_menus!
    site.hospital_categories.clear
  end
end
