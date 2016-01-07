class WxWallMessage < ActiveRecord::Base
  belongs_to :wx_wall
  belongs_to :wx_wall_user, touch: true

  scope :recent, -> { order('id DESC') }

  acts_as_wx_media :pic

  enum_attr :status, :in => [
    ['normal',    1, '正常'],
    ['unchecked', 2, '未审核'],
    ['blacklist', 3, '已拉黑'],
    ['deleted',   4, '已删除']
  ]

  acts_as_enum :msg_type, :in => [ ['text', '文本'], ['image', '图片'] ]

  def message_css
    if text?
      return "biger" if message.length <= 12
      return "big" if message.length > 12 && message.length <= 42
      return "normal"
    else
      return "img"
    end
  end

end
