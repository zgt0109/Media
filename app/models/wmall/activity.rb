class Wmall::Activity < ActiveRecord::Base
  # categories: [:banner,:common], status: {:on, :off}
  acts_as_taggable_on :categories, :statuses

  def pic_url
    if pre_pic_url.present?
      pre_pic_url
    elsif pic_key.present?
      qiniu_image_url(pic_key)
    else
      ""
    end
  end
end
