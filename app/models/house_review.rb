class HouseReview < ActiveRecord::Base
  belongs_to :house

  validates_presence_of :house_id, :author, :content, :title, :author_title, :author_description
  #validates_presence_of :avatar_key
  validates_numericality_of :position, greater_than_or_equal_to: 0, allow_nil: true

  def avatar_url
    avatar_key.present? ? qiniu_image_url(avatar_key) : ""
  end
end
