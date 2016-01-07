# == Schema Information
#
# Table name: college_teachers
#
#  id          :integer          not null, primary key
#  college_id  :integer          not null
#  name        :string(255)      not null
#  position    :string(255)
#  avatar      :string(255)
#  intro       :text
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CollegeTeacher < ActiveRecord::Base
	mount_uploader :avatar, CollegeTeacherLogoUploader
  store :meta, accessors: [ :qiniu_avatar_key ]
  img_is_exist({avatar: :qiniu_avatar_key}) 

  # attr_accessible :title, :body
  belongs_to :college

  validates :name, :position, presence: true
  #validates :avatar, presence: true, on: :create


  def avatar_url
    qiniu_image_url(qiniu_avatar_key).presence || avatar
  end
end
