class WxWallUser < ActiveRecord::Base
  EXIT_CODE = '0'
  LIVE_MINUTES = 30
  belongs_to :wx_user
  belongs_to :wx_wall
  has_many :wx_wall_messages
  has_many :award_prizes, class_name: 'WxWallPrizesWxWallUser'
  has_many :wx_wall_prizes_wx_wall_users

  acts_as_wx_media :avatar
  alias_method :avatar_url, :avatar

  scope :full, -> { where('nickname IS NOT NULL AND avatar IS NOT NULL') }
  scope :recent, -> { order('id DESC') }
  scope :signin_users, ->(ids) { where('id not in (?)', ids) if ids.present?}

  enum_attr :status, :in => [
    ['normal',    1, '正常'],
    ['blacklist', 2, '已拉黑'],
    ['deleted',   3, '已删除']
  ]

  enum_attr :matched_mode, :in => [
    ['null_mode',     0, '无'],
    ['wx_wall_mode',  1, '微信墙'],
    ['nickname_mode', 2, '昵称'],
    ['avatar_mode',   3, '头像'],
    ['message_mode',  4, '留言']
  ]

  def self.win_user(wx_user, users)
    html = ''
    if wx_user.present?
      li_a = users[0].blank? ? '<li></li>' : %Q(<li><img src="#{users[0].avatar_url || '/assets/bg_fm.jpg'}" width="46" height="46"><span>#{users[0].nickname}</span></li>)
      li_b = %Q(<li><img src="#{wx_user.avatar || '/assets/bg_fm.jpg'}" width="46" height="46"><span>#{wx_user.nickname}</span></li>)
      li_c = users[1].blank? ? '<li></li>' : %Q(<li><img src="#{users[1].avatar_url || '/assets/bg_fm.jpg'}" width="46" height="46"><span>#{users[1].nickname}</span></li>)
      html = li_a + li_b + li_c
    end
    html
  end

  def self.last_replied
    order('updated_at DESC').first
  end

  def self.reply_or_create(wx_user, activity)
    wx_wall_user = wx_user.wx_wall_users.where(wx_wall_id: activity.activityable_id).first
    return wx_wall_user.reply_welcome_message if wx_wall_user
    wx_wall_user = wx_user.wx_wall_users.create(wx_wall_id: activity.activityable_id, nickname: wx_user.nickname, avatar: wx_user.headimgurl, matched_at: Time.now)
    wx_user.wx_wall_mode!
    if wx_wall_user.nickname.blank?
      wx_wall_user.reply_need_nickname
    elsif wx_wall_user.avatar.blank?
      wx_wall_user.reply_upload_avatar
    else
      wx_wall_user.update_attributes(matched_mode: MESSAGE_MODE, matched_at: Time.now)
      "1、您现在已进入“#{activity.name}”的刷屏模式，现在可以发送您的留言内容；\n2、更换头像请回复“1”；\n3、取消刷屏模式请回复“0”；"
    end
  end

  def matched?
    !null_mode? && wx_wall.setted? && matched_at && (matched_at > LIVE_MINUTES.minutes.ago)
  end

  def reply_wx_message(msg, msg_type = 'text')
    return false unless matched?
    wx_user.wx_wall_mode!
    return false if wx_wall.vote.try(:keyword) == msg # 如果是投票关键词，则不作处理
    return into_wx_shake if wx_wall.shake.try(:keyword) == msg # 如果是摇一摇关键词，则不作处理
    return false if wx_wall.enroll.try(:keyword) == msg # 如果是报名关键词，则不作处理
    return reply_exit_message if msg == EXIT_CODE

    # 用户输入的是领奖关键词，则回复用户获奖信息
    if wx_wall.award_keyword == msg
      reply_award_message
    elsif wx_wall_mode?
      reply_welcome_message
    elsif nickname_mode?
      touch and return "1、请回复您的“姓名”进入“#{wx_wall.activity.name}”；\n2、取消进入请回复“0”；" if msg_type != 'text'
      save_nickname_and_reply_need_avatar(msg)
    elsif avatar_mode?
      touch and return "1、请回复一张图片作为您的头像；\n2、取消进入请回复“0”；" if msg_type != 'image'
      save_avatar_and_reply_goto_leave_message(msg)
    elsif message_mode?
      touch and return reply_upload_avatar if msg == '1'
      leave_message(msg, msg_type)
    end
  end

  def into_wx_shake
    update_attributes(matched_at: Time.now, matched_mode: NULL_MODE)
    return false
  end

  def reply_welcome_message
    wx_user.wx_wall_mode!
    return reply_need_nickname if nickname.blank?
    return reply_upload_avatar if avatar.blank?
    update_attributes(avatar: avatar, matched_at: Time.now, matched_mode: MESSAGE_MODE)
    "欢迎进入“#{wx_wall.activity.name}”！取消进入请回复“0”。"
  end

  def reply_exit_message
    update_attributes(matched_at: Time.now, matched_mode: NULL_MODE)
    wx_user.normal!
    '您已退出微信墙，非常感谢您的参与！'
  end

  def reply_need_nickname
    update_attributes(matched_at: Time.now, matched_mode: NICKNAME_MODE)
    "1、请回复您的“姓名”进入“#{wx_wall.activity.name}”；\n2、取消进入请回复“0”；"
  end

  def save_nickname_and_reply_need_avatar(name)
    update_attributes(nickname: name, matched_at: Time.now, matched_mode: AVATAR_MODE)
    "1、请回复一张图片作为您的头像；\n2、取消进入请回复“0”；"
  end

  def save_avatar_and_reply_goto_leave_message(avatar)
    update_attributes(avatar: avatar, matched_at: Time.now, matched_mode: MESSAGE_MODE)
    "1、您现在已进入“#{wx_wall.activity.name}”的刷屏模式，现在可以发送您的留言内容；\n2、更换头像请回复“1”；\n3、取消刷屏模式请回复“0”；"
  end

  def leave_message(msg, msg_type = 'text')
    # return if msg_type != 'text'
    msg_status    = wx_wall.verify_message? ? WxWallMessage::UNCHECKED : WxWallMessage::NORMAL
    msg_status    = WxWallMessage::BLACKLIST unless normal?
    message_attrs = { wx_wall_id: wx_wall_id, msg_type: msg_type, status: msg_status }
    message_attrs.merge!(msg_type == 'text' ? { message: msg } : { pic: msg })
    wx_wall_messages.create!(message_attrs)
    "1、发送成功#{'，请等待审核' if wx_wall.verify_message?}！再次发送请直接回复；#{wx_wall_link}\n2、取消刷屏模式请回复“0”；"
  end

  def reply_upload_avatar
    update_attributes(matched_at: Time.now, matched_mode: AVATAR_MODE)
    "1、请回复一张图片作为您的头像；\n2、取消进入请回复“0”；"
  end

  def reply_award_message
    prizes = award_prizes.pending
    return '很抱歉，您没有中奖' if prizes.blank?
    text = '恭喜您，' << prizes.map { |prize| "获得了“#{prize.prize_name}”！中奖SN码：#{prize.sn_code}，" }.join
    text << "兑换奖品时请向工作人员出示；取消刷屏模式请回复“0”；#{wx_wall_link}"
  end

  def wx_wall_link
    %Q(<a href="http://#{Settings.mhostname}/#{wx_wall.supplier_id}/wx_walls/#{wx_wall_id}">点击查看微信墙</a>)
  end

  def nickname
    super.to_s[0..15]
  end

end
