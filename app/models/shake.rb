class Shake < ActiveRecord::Base
	belongs_to :site
	has_one :activity, as: :activityable, conditions: { activity_type_id: ActivityType::SHAKE }
	has_many :shake_users
  has_many :shake_rounds
  has_many :shake_prizes

	accepts_nested_attributes_for :activity

  validates :mode_value, :prize_user_num, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :countdown, presence: true, numericality: { greater_than_or_equal_to: 5, less_than: 100, only_integer: true }

	enum_attr :template_id, :in => [
    ['template1', 1, '漫威英雄'],
    ['template2', 2, '2014世界杯']
  ]

  enum_attr :status, :in => [
    ['normal',   1, '已开启'],
    ['stopped', -1, '已停止'],
    ['deleted', -2, '已删除']
  ]

  %i(name keyword summary).each do |method_name|
    delegate method_name, to: :activity, allow_nil: true
  end

  scope :show, -> {where(status: [NORMAL, STOPPED])}

  def logo_url
    qiniu_image_url(logo_key)
  end

end
