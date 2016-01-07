class WxInvite < ActiveRecord::Base
  # attr_accessible :title, :body
  scope :recommend, ->{where(is_recommend: true)}
  scope :recommended, ->{where(is_recommended: true)}
  scope :pending_recommend, ->{where(is_recommended: false)}

  belongs_to :wx_participate

  def activity
    Activity.find_by_id(wx_invitable_id) if wx_invitable_type == 'Activity'
  end

  def activity_id
    wx_invitable_id if wx_invitable_type == 'Activity'
  end

  def recommended!
    update_attributes(is_recommended: true)
    if from_wx_user.present?
      from_participate = from_wx_user.wx_participates.normal.find_by_activity_id(activity_id)
      if from_participate.present?
          from_participate.check_prize!(to_wx_user_id)
      end
    end
  end

  def from_wx_user
    WxUser.find_by_id(from_wx_user_id)
  end

  def to_wx_user
    WxUser.find_by_id(to_wx_user_id)
  end

end
