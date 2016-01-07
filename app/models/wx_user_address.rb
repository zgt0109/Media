class WxUserAddress < ActiveRecord::Base
  belongs_to :wx_user
  belongs_to :province
  belongs_to :city
  belongs_to :district

  validates :wx_user, :username, :tel, :address, presence: true

  enum_attr :status, :in => [
    ['normal',   0,  '正常'],
    ['deleted',  -1, '已删除']
  ]

  enum_attr :is_default, :in => [
      ['default',   true,  '默认'],
      ['not_default',  false, '未默认']
  ]

  def province_city
    str = province ? province.name : ''
    str << " #{city.name}" if city
    str
  end

  def detail_info
    [province.try(:name), city.try(:name), address].compact.join
  end

end
