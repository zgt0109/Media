class ActivityNotice < ActiveRecord::Base

  enum_attr :activity_status, :in => [
    ['stopped', -1, '已结束'],
    ['ready', 0, '预热中'],
    ['active', 1, '进行中']
  ]

  validates :title, presence: true, length: { maximum: 64 }

  belongs_to :activity
  delegate :activity_type_id, to: :activity, allow_nil: true

  class << self
    def new_ready_notice_by_type( activity_type_id )
      case activity_type_id.to_i
      when 3  then coupon_ready_notice
      when 4  then gua_ready_notice
      when 5  then wheel_ready_notice
      when 25 then hit_egg_ready_notice
      end
    end

    def coupon_ready_notice
      new(title: '活动即将开始', pic_key: 'FoIsarMzfL1wgy7nTeUDmmYqNXgo', summary: '您参与的优惠券活动将在{day}天{hour}小时{minute}分钟后开始！更多活动细节请点击页面查看详情~', description: "活动预热说明", activity_status: 0)
    end

    def gua_ready_notice
      new(title: '活动即将开始', pic_key: 'Fkgsh_bQL0bVzzB--_vlgXh_XEg-', summary: '请点击进入刮刮卡活动预热页面', description: "活动预热说明", activity_status: 0)
    end

    def wheel_ready_notice
      new(title: '活动即将开始', pic_key: 'Fl-25j4H93sfZ-B0ouwCusJfXK7D', summary: '请点击进入幸运大转盘活动预热页面', description: "活动预热说明", activity_status: 0)
    end

    def hit_egg_ready_notice
      new(title: '活动即将开始', pic_key: 'FtGXJcP77amXP66bzhbZxirbO2pu', summary: '请点击进入砸金蛋活动预热页面', description: "活动预热说明", activity_status: 0)
    end

    def ready_or_active_notice(activity, ready_statuses = [Activity::WARM_UP])
      if ready_statuses.include?(activity.activity_status)
        activity.activity_notices.ready.first
      else
        activity.activity_notices.active.first
      end
    end

    def website_notice(activity)
      activity_notice = activity.activity_notices.active.first
      if activity_notice
        activity_notice.summary.to_s.gsub!('{name}', activity.website.try(:name).to_s)
      end
      activity_notice
    end

    def vip_notice(activity, openid)
      wx_user = WxUser.where(openid: openid).first
      vip_user = activity.site.vip_users.where('vip_users.user_id = ? and vip_users.status <> ?', wx_user.user_id, VipUser::DELETED).first
      return activity.activity_notices.ready.first unless vip_user

      activity_notice = activity.activity_notices.active.first
      if vip_user.pending?
        activity_notice.title = activity_notice.summary = '您的会员卡正在审核中'
      elsif vip_user.rejected?
        activity_notice.title = activity_notice.summary = '您的会员卡申请已被拒绝'
      elsif vip_user.inactive?
        activity_notice.title = '激活微信会员卡'
        activity_notice.summary = "您已获得#{vip_user.usable_points}积分，激活微信会员卡享受积分消费特权！"
      else
        activity_notice.title.to_s.gsub!('{name}', vip_user.name)
        activity_notice.summary.to_s.gsub!('{name}', vip_user.name)
        activity_notice.summary.to_s.gsub!('{card_id}', vip_user.user_number)
      end
      activity_notice
    end

  def default_pic_url
    qiniu_image_url(Concerns::ActivityQiniuPicKeys::KEY_MAPS[activity_type_id])
  end

  def pic_url
    qiniu_image_url(pic_key) || default_pic_url
  end

end
