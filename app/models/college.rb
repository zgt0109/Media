# == Schema Information
#
# Table name: colleges
#
#  id            :integer          not null, primary key
#  supplier_id   :integer          not null
#  wx_mp_user_id :integer          not null
#  name          :string(255)      not null
#  tel           :string(255)
#  intro         :text
#  security      :text
#  logo          :string(255)
#  ad_pic        :string(255)
#  status        :integer          default(1)
#  description   :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class College < ActiveRecord::Base
  store :meta, accessors: [ :logo_key, :qiniu_add_pic_key ]

  validates :name, :tel, presence: true

  belongs_to :site
  belongs_to :wx_mp_user
  has_one  :activity, as: :activityable, dependent: :destroy

  
  has_many :majors,   class_name: "CollegeMajor",   dependent: :destroy
  has_many :teachers, class_name: "CollegeTeacher", dependent: :destroy
  has_many :photos,   class_name: "CollegePhoto",   dependent: :destroy
  has_many :enrolls,  class_name: "CollegeEnroll",  dependent: :destroy
  has_many :branches, class_name: 'CollegeBranch',  dependent: :destroy

  accepts_nested_attributes_for :activity


  def logo_url
    qiniu_image_url(logo_key).presence || logo
  end

  def add_pic_url
    qiniu_image_url(qiniu_add_pic_key).presence || ad_pic
  end
end
