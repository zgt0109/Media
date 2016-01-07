class VipGrade < ActiveRecord::Base
  belongs_to :vip_card
  has_many :vip_users
  has_and_belongs_to_many :vip_privileges
  has_and_belongs_to_many :point_gifts

  scope :sorted, -> { order('status ASC, sort ASC') }
  scope :reverse_sorted, -> { order('status DESC, sort DESC') }
  scope :sort_greater_than, ->(sort) { where("sort >= ?", sort) }
  scope :visible, -> { where(status: [DEFAULT, NORMAL]) }
  
  validates :name, presence: true, uniqueness: { scope: [:vip_card_id, :status], message: '等级名称不能重复' }, if: :normal?
  validates :sort, :value, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }, if: :normal?
  validates :sort, uniqueness: { scope: [:vip_card_id, :status], message: '等级值不能重复' }, if: :normal?
  validates :name, uniqueness: { scope: [:vip_card_id, :status], message: '等级名称不能重复' }, if: :normal?

  enum_attr :category, :in => [
    ['by_time',       1, '按时间使用'],
    ['by_points',     2, '按累计积分'],
    ['by_recharging', 3, '按累计充值金额'],
    ['by_consuming',  4, '按累计消费金额']
  ]

  enum_attr :status, :in => [
    ['default',  0, '默认'],
    ['normal',   1, '正常'],
    ['deleted',  2, '已删除']
  ]

  def visible?
    normal? || default?
  end

  def cover_attributes(index)
    {
      level: name,
      number: 'No.2015236541',
      tplId: "tpl0#{index + 1}",
      cardLevelColor: '#eb5c87',
      cardNumberColor: '#eb5c87',
      cardBg: 'http://vcl-pictures.qiniucdn.com/Flku4iCXcXKeO7GynEga3oXRxS1o'
    }
  end

end
