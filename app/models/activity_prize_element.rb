class ActivityPrizeElement < ActiveRecord::Base
  mount_uploader :pic, ActivityPrizeElementUploader
  img_is_exist({pic: :qiniu_pic_key})

  validates :name, presence: true

  belongs_to :activity
  has_many :activity_prizes, through: :prize_elements
  has_many :prize_elements
  scope :with_name,  -> { where("name is not null") }
  
  def self.default_qiniu_pic_key
    'Ftb5bwV2gRKzcHm_2yHeufrjGkbZ'
  end

  def pic_url(type = :thumb)
    qiniu_image_url(qiniu_pic_key) || pic.try(type)
  end
end
