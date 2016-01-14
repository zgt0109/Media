class HouseSeller < ActiveRecord::Base

  belongs_to :site
  belongs_to :house

  validates :name, :phone, :position, :skilled_language, presence: true

  enum_attr :status, :in => [
    ['normal',   1,  '正常'],
    ['deleted',  -1, '已删除'],
  ]

  def pic_url
    if pic_key.present?
      qiniu_image_url(pic_key)
    else
      default_pic_url
    end
  end

  def default_pic_url
    qiniu_image_url('FtMSS5pbNsj_iYkMtU__omjofc5N')
  end

end
