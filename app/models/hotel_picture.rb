# == Schema Information
#
# Table name: hotel_pictures
#
#  id              :integer          not null, primary key
#  hotel_id        :integer          not null
#  hotel_branch_id :integer          not null
#  name            :string(255)
#  path            :string(255)      not null
#  is_cover        :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class HotelPicture < ActiveRecord::Base
  mount_uploader :path, HotelPictureUploader
  img_is_exist({path: :qiniu_path_key})

  validates :hotel_branch_id, presence: true

  belongs_to :hotel_branch
  belongs_to :hotel

  def cover!
    update_attributes!(is_cover: true) unless is_cover
  end

  def discover!
    update_attributes!(is_cover: false) if is_cover
  end

  def path_url(type = :large)
    qiniu_image_url(qiniu_path_key) || path.try(type)
  end

end
