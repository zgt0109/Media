class ActivitySetting < ActiveRecord::Base
  belongs_to :activity
  has_one :associated_activity, class_name: 'Activity', foreign_key: 'id', primary_key: 'associated_activity_id'

  acts_as_enum :user_type, in: [
    ['all_user', 1, '全体用户'],
    ['wx_user',  2, '关注用户'],
    ['vip_user', 3, '仅会员可参加']
  ]

  acts_as_enum :vote_result_sort_way, in: [
    ['sort_desc',     1, '按结果从高到低排序'],
    ['sort_original', 2, '按照原始排序'],
  ]


  validates :user_type, presence: true, inclusion: {in: USER_TYPES.keys, message: "参与用户必须为：#{USER_TYPES.values.join('、')} 之一"}
  
end
