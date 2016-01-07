# == Schema Information
#
# Table name: house_pictures
#
#  id              :integer          not null, primary key
#  house_id        :integer          not null
#  house_layout_id :integer
#  name            :string(255)
#  path            :string(255)      not null
#  is_cover        :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class HousePicture < ActiveRecord::Base
  mount_uploader :path, HousePictureUploader

  # validates :path, presence: true, on: :create

  belongs_to :house_layout

  enum_attr :is_cover, :in => [
      ['cover', 1, '封面图片'],
      ['common', 0, '普通图片']
  ]

  img_is_exist({path: :pic_key})

	def cover!
		update_attributes(is_cover: true) unless is_cover
	end

	def discover!
		update_attributes(is_cover: false) if is_cover
	end

  def pic_url
    if pic_key.present?
      qiniu_image_url(pic_key)
    elsif path.to_s.present?
      path.try(:large).to_s
    else
      ""
    end
  end
end
