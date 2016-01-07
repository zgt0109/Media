class Wmall::Product < ActiveRecord::Base
  acts_as_taggable_on :statuses, :categories
  belongs_to :shop

  after_initialize :generate_sn

  def pic_url
    if pre_pic_url.present?
      pre_pic_url
    elsif pic_key.present?
      qiniu_image_url(pic_key)
    else
      ""
    end
  end

  private
  def generate_sn
    self.sn = generate_sn_by_timestamp unless sn.present?
  end
end
