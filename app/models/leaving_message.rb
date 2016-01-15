class LeavingMessage < ActiveRecord::Base
  belongs_to :site
  belongs_to :replier,  polymorphic: true
  belongs_to :parent,   class_name:  'LeavingMessage'
  has_many   :children, class_name:  'LeavingMessage', foreign_key: 'parent_id'

  enum_attr :status, :in => [['init',1,'待审核'],['audited',2,'通过'],['denied',3,'拒绝']]

  scope :audited, -> { where(status: 2) }
  scope :root, -> { where(parent_id: nil) }

  validates :body, presence: true

  def nickname
    lm_nickname = self.attributes.fetch('nickname') || replier.try(:nickname)
    lm_nickname = "匿名用户" if lm_nickname.blank?
    lm_nickname
  end

  def root
    parent || self
  end

  def check!
    update_attributes(status: 2)
  end

  def deny!
    update_attributes(status: 3)
  end

  def forbid_replier!
    replier.wx_user.update_attributes(leave_message_forbidden: true)
  end

  def cancel_forbid_replier!
    replier.wx_user.update_attributes(leave_message_forbidden: false)
  end

  def replier_status
    if replier_type == "User" && replier.wx_user.try(:leave_message_forbidden) == true
      "此用户已加入黑名单"
    end
  end
end

