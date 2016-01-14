# coding: utf-8
class WxUser < ActiveRecord::Base
  acts_as_follower

  MATCH_TYPE_OPTIONS = [
    ['normal', 1, '正常模式'],
    ['postcard', 2, '打印模式'],
    ['share_photos', 3, '晒图模式'],
    ['greet', 4, '贺卡模式'],
    ['house_live_photos', 5, '实景拍摄模式'],
    ['wx_print', 6, '微信打印模式'],
    ['wifi', 7, 'wifi模式'],
    ['weixin_print', 8, '微信打印模式(不再使用)'],
    ['hanming_wifi', 9, '汉明wifi'],
    ['kefu', 10, '人工客服模式'],
    ['kefu_rate', 11, '人工客服评价模式'],
    ['wx_wall_mode', 12, '微信墙模式'],
    ['shake_mode', 13, '摇一摇模式']
  ]
  enum_attr :match_type, in: MATCH_TYPE_OPTIONS

  enum_attr :subscribe, :in => [
    ['unsubscribe', 0, '未关注'],
    ['subscribed',  1, '已关注']
  ]

  acts_as_enum :sex, :in => [
    ['secret', 0, '未知'],
    ['male', 1, '男'],
    ['female', 2, '女'],
  ]

  validates :openid, presence: true

  belongs_to :user
  belongs_to :wx_mp_user

  has_many :wx_wall_users
  has_many :wx_participates
  has_many :wx_prizes
  has_many :addresses, class_name: 'WxUserAddress', dependent: :destroy

  scope :message_forbidden, ->{ where(leave_message_forbidden: 1)}
  scope :message_normal, ->{ where(leave_message_forbidden: 0)}

  after_create :init_user

  # Options: wx_user_openid, wx_mp_user_openid
  def self.follow(wx_mp_user, options = {})
    return unless wx_mp_user

    options = HashWithIndifferentAccess.new(options)
    wx_mp_user.update_openid_to(options[:wx_mp_user_openid])
    wx_user = wx_mp_user.wx_users.where(openid: options[:wx_user_openid]).first_or_create

    attrs = { wx_mp_user_id: wx_mp_user.id }
    attrs.merge!(subscribe: options[:subscribe]) if options[:subscribe].present?
    wx_user.attributes = attrs
    wx_user.save if wx_user.changed?

    wx_user.check_recommend

    wx_user
  end

  def to_s
    nickname || openid || id.to_s
  end

  def check_recommend
    recommend =  WxInvite.recommend.pending_recommend.where(to_user_id: user_id).last
    return unless recommend

    if wx_mp_user && wx_mp_user.auth_service? && wx_mp_user.is_oauth?
      attrs = Weixin.get_wx_user_info(wx_mp_user, openid).to_h
      attrs['nickname'] = attrs['nickname'].to_s.chars.select { |c| c.ord <= 65535 }.join if attrs['nickname'].present?
      if attrs.present?
        self.attributes = attrs
        save if changed?
      end
    end
    recommend.recommended!
  end

  MATCH_TYPE_OPTIONS.map(&:first).each do |match_type|
    define_method "#{match_type}!" do
      update_attributes(match_type: WxUser.const_get(match_type.upcase), match_at: Time.now)
    end
  end

  def axis
    "#{location_x}, #{location_y}"
  end

  def reset_match_type
    normal! if greet? && updated_at <= 5.minutes.ago
  end

  def has_info?
    nickname.present? && headimgurl.present?
  end

  def logo_url
    headimgurl || '/assets/wx_wall/user-img.jpg'
  end

  def enter_kefu?
    normal? || kefu? || kefu_rate?
  end

  def enter_wx_wall?
    wx_wall_mode? && matched_in_minutes?(WxWallUser::LIVE_MINUTES)
  end

  def enter_shake?
    shake_mode? && matched_in_minutes?(ShakeUser::LIVE_MINUTES)
  end

  def enter_postcard?
    postcard? && matched_in_minutes?(2)
  end

  def matched_in_minutes?(minutes)
    matched = match_at && match_at > minutes.minutes.ago
    normal! unless matched
    matched
  end

  def setup_user
    user || init_user
  end

  private

  def init_user
    user = User.create(site_id: wx_mp_user.site_id)
    update_attributes(user_id: user.try(:id))
  end
end
