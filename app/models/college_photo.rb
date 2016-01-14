class CollegePhoto < ActiveRecord::Base

  belongs_to :college
  validates :name, presence: true

  def pic_url
    qiniu_image_url(pic_key)
  end
end
