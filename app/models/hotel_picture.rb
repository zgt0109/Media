class HotelPicture < ActiveRecord::Base

  validates :hotel_branch_id, presence: true

  belongs_to :hotel_branch
  belongs_to :hotel

  def cover!
    update_attributes!(is_cover: true) unless is_cover
  end

  def discover!
    update_attributes!(is_cover: false) if is_cover
  end

  def path_url
    qiniu_image_url(qiniu_path_key)
  end

end
