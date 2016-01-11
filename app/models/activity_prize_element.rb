class ActivityPrizeElement < ActiveRecord::Base

  validates :name, presence: true

  belongs_to :activity
  has_many :activity_prizes, through: :prize_elements
  has_many :prize_elements
  scope :with_name,  -> { where("name is not null") }

  def self.default_pic_key
    'Ftb5bwV2gRKzcHm_2yHeufrjGkbZ'
  end

  def pic_url
    qiniu_image_url(pic_key)
  end
end
