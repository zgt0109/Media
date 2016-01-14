class CollegeTeacher < ActiveRecord::Base
  store :meta, accessors: [ :qiniu_avatar_key ]

  belongs_to :college

  validates :name, :position, presence: true


  def avatar_url
    qiniu_image_url(qiniu_avatar_key).presence
  end
end
