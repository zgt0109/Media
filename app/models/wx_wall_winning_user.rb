class WxWallWinningUser < ActiveRecord::Base
	belongs_to :wx_wall
  belongs_to :vip_user
  belongs_to :wx_user

  enum_attr :status, :in => [
    ['normal',   1, '正常'],
    ['awarded',  2, '已抽奖'],
    ['deleted', -1, '已删除']
  ]
end
