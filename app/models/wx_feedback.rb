class WxFeedback < ActiveRecord::Base
  # attr_accessible :title, :body

  acts_as_enum :msg_type, :in => [
      ['request', 0, "提交"],
      ['confirm', 1, "确认消除"],
      ['reject', 2, "拒绝消除"]
  ]

  MSGTYPE = [['request',0],['confirm',1],['reject',2]]


  def self.msg_type_status status
    MSGTYPE.select{|t| break t[1] if t[0] == status}
  end

end
