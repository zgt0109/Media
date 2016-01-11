class Feedback < ActiveRecord::Base
  validates :feedback_type, :account_id, :content, presence: true

  belongs_to :admin_user
  belongs_to :account
  belongs_to :sub_account

  enum_attr :feedback_type, :in=>[
    ['product_proposal', 1, '产品建议'],
    ['error_feedback', 2, '错误反馈'],
    ['complain', 3, '投诉'],
  ]

  enum_attr :status, :in=>[
    ['unreply', 1, '未回复'],
    ['replied', 2, '已回复'],
  ]
end
