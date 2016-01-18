class BrochePhoto < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :title, :pic_key, presence: true
  validates :sort, numericality: {only_integer: true}
  belongs_to :broche
  belongs_to :site

  def pic
    qiniu_image_url pic_key
  end



end
