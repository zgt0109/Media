class HouseSeller < ActiveRecord::Base

  belongs_to :site
  belongs_to :wx_mp_user
  belongs_to :house

  before_save :set_pic_key

  validates :name, :phone, :position, :skilled_language, presence: true
  # validates :pic, presence: true, on: :create

  enum_attr :status, :in => [
    ['normal',   1,  '正常'],
    ['deleted',  -1, '已删除'],
  ]

  img_is_exist({pic: :pic_key})

  def pic_url
    if pic_key.present?
      qiniu_image_url(pic_key)
    elsif pic.present?
      pic.try(:large).to_s
    else
      default_pic_url
    end
  end

  def default_pic_url
    qiniu_image_url(default_pic_key)
  end

  def default_pic_key
    'FtMSS5pbNsj_iYkMtU__omjofc5N'
  end

  private
    def set_pic_key
      self.pic_key = default_pic_key if pic.blank?
    end
end
