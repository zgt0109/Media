# == Schema Information
#
# Table name: wedding_pictures
#
#  id         :integer          not null, primary key
#  wedding_id :integer          not null
#  name       :string(255)
#  is_cover   :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WeddingPicture < ActiveRecord::Base
	mount_uploader :name, PictureUploader
  img_is_exist({name: :pic_key})

  belongs_to :wedding

  scope :cover, -> { where(is_cover: true) }

  img_is_exist({name: :pic_key})

  def pic_url
    if pic_key.present?
      qiniu_image_url(pic_key)
    elsif name.to_s.present?
      name.try(:large).to_s
    else
      ""
    end
  end
end
