class ShakeUser < ActiveRecord::Base
	EXIT_CODE = '0'
  LIVE_MINUTES = 30

	belongs_to :user
  belongs_to :shake
  has_many :shake_prizes
	enum_attr :status, :in => [
    ['null_at',      0, '无'],
    ['shake_at',  1, '摇一摇'],
    ['nickname_at',  2, '昵称'],
    ['avatar_at',    3, '头像'],
    ['mobile_at',    4, '手机']
  ]

  acts_as_wx_media :avatar

  scope :normal_user, -> {where('matched_at > ?', LIVE_MINUTES.minutes.ago)}

  def get_user_rank(shake_round_id)
    shake_prizes.where(shake_round_id: shake_round_id).first.try(:user_rank)
  end

  def reply_keyword?
    shake_at? && matched_at && matched_at > LIVE_MINUTES.minutes.ago && shake.normal?
  end

  def self.last_replied
    order('updated_at DESC').first
  end

  def reply_exit_message
    user.wx_user.normal!
    update_attributes(matched_at: Time.now, status: NULL_AT)
    '您已退出摇一摇，非常感谢您的参与！'
  end

  def reply_need_nickname
    update_attributes(matched_at: Time.now, status: NICKNAME_AT)
    "1、请回复您的“姓名”进入“#{shake.name}”；\n2、取消进入请回复“0”；"
  end

  def reply_change_avatar
    update_attributes( matched_at: Time.now, status: AVATAR_AT )
    "1、请回复一张图片作为您的头像；\n2、取消进入请回复“0”；"
  end

  def reply_change_mobile
    update_attributes( matched_at: Time.now, status: MOBILE_AT )
    "1、请回复您的“手机号”进入“#{shake.name}”；\n2、取消进入请回复“0”；"
  end

  def reply_welcome_message
    user.wx_user.shake_mode!
    return reply_need_nickname if nickname.blank?
    return reply_change_avatar if avatar.blank?
    return reply_change_mobile if mobile.blank? && shake.mobile_check?
    update_attributes( nickname: nickname, avatar: avatar, mobile: mobile, matched_at: Time.now, status: WX_SHAKE_AT )
    return false
  end

  def save_nickname_and_reply_need_avatar( name )
    update_attributes( nickname: name, matched_at: Time.now, status: AVATAR_AT )
    "1、请回复一张图片作为您的头像；\n2、取消进入请回复“0”；"
  end

  def save_avatar_and_reply_goto_leave_message( avatar )
    if shake.mobile_check?
      update_attributes( avatar: avatar, matched_at: Time.now, status: MOBILE_AT )
      "1、请回复您的“手机号”进入“#{shake.name}”；\n2、取消进入请回复“0”；"
    else
      update_attributes( avatar: avatar, matched_at: Time.now, status: WX_SHAKE_AT )
      return false
    end
  end

  def save_mobile_and_reply_goto_leave_message( msg )
    return '请输入正确的手机号码！' if msg.to_s.size != 11
    update_attributes( mobile: msg, matched_at: Time.now, status: WX_SHAKE_AT )
    return false
  end

  def reply_wx_message( msg, msg_type = 'text' )
  	return false unless matched_at && matched_at > LIVE_MINUTES.minutes.ago
    return false unless shake.normal?
    return reply_exit_message if !null_at? && msg == EXIT_CODE

    user.wx_user.shake_mode!
    if shake_at?
      reply_welcome_message
    elsif nickname_at?
      touch and return "1、请回复您的“姓名”进入“#{shake.name}”；\n2、取消进入请回复“0”；" if msg_type != 'text'
      save_nickname_and_reply_need_avatar( msg )
    elsif avatar_at?
      touch and return "1、请回复一张图片作为您的头像；\n2、取消进入请回复“0”；" if msg_type != 'image'
      save_avatar_and_reply_goto_leave_message( msg )
    elsif mobile_at?
      touch and return "1、请回复您的“手机号”进入“#{shake.name}”；\n2、取消进入请回复“0”；" if msg_type != 'text'
      save_mobile_and_reply_goto_leave_message( msg )
    end
  end

  def self.reply_or_create( user, activity )
    return false unless activity.activityable.normal?
    shake_user = user.shake_users.where(shake_id: activity.activityable_id).first
    return shake_user.reply_welcome_message if shake_user
    shake_user = user.shake_users.create(site_id: activity.site_id, shake_id: activity.activityable_id, nickname: user.nickname, avatar: user.headimgurl, mobile: user.mobile, matched_at: Time.now)
    user.wx_user.shake_mode!
    if shake_user.nickname.blank?
      shake_user.reply_need_nickname
    elsif shake_user.avatar.blank?
      shake_user.save_nickname_and_reply_need_avatar(shake_user.nickname)
    elsif shake_user.mobile.blank?
      shake_user.save_avatar_and_reply_goto_leave_message(shake_user.avatar)
    end
  end

  def nickname
    super.to_s[0..15]
  end

end
