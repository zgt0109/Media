# == Schema Information
#
# Table name: college_photos
#
#  id          :integer          not null, primary key
#  college_id  :integer          not null
#  name        :string(255)      not null
#  pic         :string(255)      not null
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CollegePhoto < ActiveRecord::Base
	mount_uploader :pic, CollegePhotoUploader
	img_is_exist({pic: :qiniu_pic_key}) 
  # attr_accessible :title, :body
  belongs_to :college
  validates :name, presence: true

  def pic_url(type = :large)
    qiniu_image_url(qiniu_pic_key) || pic.try(type)
  end
end
