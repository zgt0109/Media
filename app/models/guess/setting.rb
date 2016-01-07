class Guess::Setting < ActiveRecord::Base
  belongs_to :activity
  belongs_to :prize, polymorphic: true

  USER_INFO_COLUMNS = {
    name:    '姓名',
    mobile:  '手机',
    email:   '邮箱',
    address: '地址'
  }

  acts_as_enum :user_type, in: [
    ['all_user',          1, '所有用户可参加'],
    ['wx_user',           2, '关注用户可参加'],
    ['vip_user',           3, '仅会员可参加']
  ]


  validates :user_type, presence: true, inclusion: {in: USER_TYPES.keys, message: "参与用户必须为：#{USER_TYPES.values.join('、')} 之一"}
  validates :answer_points, numericality: {greater_than: 0}, if: :use_points?
  validates :user_day_answer_limit, :user_total_answer_limit, :question_answer_limit, presence: true, numericality: {greater_than: -2}

  serialize :user_info_columns, Array

end
