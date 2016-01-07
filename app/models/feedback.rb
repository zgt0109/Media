# == Schema Information
#
# Table name: feedbacks
#
#  id            :integer          not null, primary key
#  supplier_id   :integer          not null
#  feedback_type :integer          default(1), not null
#  content       :text
#  admin_user_id :integer
#  reply         :text
#  status        :integer          default(1), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Feedback < ActiveRecord::Base
  #attr_accessible :admin_user_id, :content, :feedback_type, :reply, :status, :supplier_id
  validates :feedback_type, :supplier_id, :content, presence: true
  #validates :admin_user_id, presence: true, on: :update
  
  belongs_to :admin_user
  belongs_to :supplier
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
