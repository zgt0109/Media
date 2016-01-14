class College < ActiveRecord::Base
  store :meta, accessors: [ :logo_key, :qiniu_add_pic_key ]

  validates :name, :tel, presence: true

  belongs_to :site
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
