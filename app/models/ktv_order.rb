class KtvOrder < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :wx_mp_user
  belongs_to :wx_user
  DRINKS = %W[啤酒 汽水 伏加特 鸡尾酒 红酒]
  serialize :drinks, Array
  enum_attr :status, :in => [
    ['unchecked', 1, '未受理'],
    ['checked',   2, '已受理']
  ]
  enum_attr :room_type, :in => [
    ['mini', 1, '迷你房'],
    ['small',   2, '小房'],
    ['big', 3, '大房'],
    ['party',   4, 'Party'],
    ['middle',   5, '中房']
  ]
  def drinks_name
    drinks.join(' ')
  end
end
