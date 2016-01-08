# == Schema Information
#
# Table name: assistants
#
#  id             :integer          not null, primary key
#  name           :string(255)      not null
#  code           :string(255)
#  keyword        :string(255)
#  url            :string(255)
#  pic            :string(255)
#  sort           :integer          default(1), not null
#  status         :integer          default(1), not null
#  description    :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  assistant_type :integer          default(1), not null
#

class Assistant < ActiveRecord::Base
  validates :name, :code, presence: true
  validates :url, presence: true, format: { with: /^(http|https):\/\/[a-zA-Z0-9].+$/, message: '地址格式不正确，必须以http(s)://开头' }, if: proc{|u| u.url.present?}

  has_many :assistants_suppliers

  qiniu_image_for :pic

  enum_attr :status, :in => [
    ['enabled', 1, '已启用'],
    ['disabled', -1, '已停用']
  ]

  enum_attr :assistant_type, :in => [
    ['helpers', 1, '生活小助手'],
    ['games', 2, '休闲小游戏'],
    ['lives', 3, '微生活'],
    ['circles', 4, '微商圈'],
    ['cars', 5, '微汽车']
  ]

  WEATHERCITY = [[49,"chaoyang1"],[143,"jining1"],[144,"taian1"],[147,"linyi2"],[308,"longnan1"],[317,"yushu1"],[322,"guyuan1"],
                 [81,"huaian1"],[75,"wuxi1"],[85,"taizhou2"],[94,"quzhou1"],[112,"bozhou2"],[109,"suzhou1"],[107,"chuzhou1"],
                 [108,"fuyang1"],[132,"yichun1"],[131,"jian1"] ,[133,"fuzhou1"],[190,"yiyang1"],[255,"guiyang1"],[251,"ziyang1"],
                 [241,"suining1"],[254,"liangshan1"],[211,"qingyuan3"],[267,"baoshan1"],[276,"dali1"],[225,"yulin1"],[182, "changsha"]
  ]

  TRAINCITY = [[109,"suzhou2"],[133,"fuzhou2"],[255,"yulin2"],[182, "changsha"]]

  def self.enabled_helper(keyword)
    Assistant.helpers.enabled.where("? like concat(keyword, '%')", keyword).first
  end

  def self.respond_game(wx_user, wx_mp_user, keyword)
    keyword = keyword.to_s
    content = ' '
    content << if keyword.length == 2
                 wx_mp_user.supplier.assistants.games.enabled.map(&:weixin_link_tag).join("\n\n ").presence || '商户未开启任何游戏'
               else
                 wx_mp_user.supplier.assistants.where(name: keyword[2..-1]).first.try(:weixin_link_tag) || '游戏不存在或商户未开启此游戏'
               end
    Weixin.respond_text(wx_user.openid, wx_mp_user.openid, content)
  end

  def title
    name
  end

  def summary
    description
  end

  def open_status(supplier_id)
    assistants_suppliers.where(supplier_id: supplier_id).exists?
  end

  def close_status(supplier_id)
    !open_status(supplier_id)
  end

  def weixin_link_tag
    %Q(<a href="#{url}">#{name}</a>)
  end

  def handle_keyword(mp_user, from_user_name, keyword)
    to_user_name = mp_user.openid
    if close_status(mp_user.supplier_id)
      Weixin.respond_text(from_user_name, to_user_name, '商户已关闭此服务')
    elsif keyword.start_with?('附近')
      BaiduMapService.respond_location(from_user_name, mp_user, keyword)
    elsif keyword.start_with?('听歌')
      Weixin.respond_music_content(from_user_name, to_user_name, LifeAssistant.music(keyword.from(2)))
    else
      Weixin.respond_text(from_user_name, to_user_name, LifeAssistant.handle_keyword(keyword))
    end
  rescue => e
    Weixin.respond_text(from_user_name, to_user_name, description)
  end

  def pic
    pic_key = self[:pic]
    return if pic_key.blank?
    return ImageQiniu.new("#{WWW_HOST}/uploads/#{self.class.name.underscore}/#{__method__}/#{pic_key}") if pic_key =~ /.+\.(png|ico|jpg|jpeg|gif|bmp)$/i
    ImageQiniu.new(pic_key)
  end
end
