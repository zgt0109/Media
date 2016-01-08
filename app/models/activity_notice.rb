# == Schema Information
#
# Table name: activity_notices
#
#  id              :integer          not null, primary key
#  wx_mp_user_id   :integer          not null
#  activity_id     :integer          not null
#  title           :string(255)
#  pic             :string(255)
#  summary         :string(255)
#  description     :text
#  activity_status :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ActivityNotice < ActiveRecord::Base
  mount_uploader :pic, MaterialUploader
  img_is_exist({pic: :qiniu_pic_key}) 

  enum_attr :activity_status, :in => [
    ['stopped', -1, '已结束'],
    ['ready', 0, '预热中'],
    ['active', 1, '进行中']
  ]

  before_create :set_default_pic

  validates :title, presence: true, length: { maximum: 64 }
  # validates :pic, presence: true, on: :create
  # validates :description, presence: true, length: { maximum: 2000 }, on: :update

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
      new(title: '活动即将开始', qiniu_pic_key: 'FoIsarMzfL1wgy7nTeUDmmYqNXgo', summary: '您参与的优惠券活动将在{day}天{hour}小时{minute}分钟后开始！更多活动细节请点击页面查看详情~', description: "活动预热说明", activity_status: 0)
    end

    def gua_ready_notice
      new(title: '活动即将开始', qiniu_pic_key: 'Fkgsh_bQL0bVzzB--_vlgXh_XEg-', summary: '请点击进入刮刮卡活动预热页面', description: "活动预热说明", activity_status: 0)
    end

    def wheel_ready_notice
      new(title: '活动即将开始', qiniu_pic_key: 'Fl-25j4H93sfZ-B0ouwCusJfXK7D', summary: '请点击进入幸运大转盘活动预热页面', description: "活动预热说明", activity_status: 0)
    end

    def hit_egg_ready_notice
      new(title: '活动即将开始', qiniu_pic_key: 'FtGXJcP77amXP66bzhbZxirbO2pu', summary: '请点击进入砸金蛋活动预热页面', description: "活动预热说明", activity_status: 0)
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
      vip_user = activity.supplier.vip_users.where('vip_users.status <> ?', VipUser::DELETED).joins(:wx_user).where('wx_users.uid = ?', openid).first
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

    def respond_old_coupon(wx_user, wx_mp_user, activity)
      return Weixin.respond_text(wx_user.uid, wx_mp_user.uid, '活动还未开始') unless activity.setted?

      options = {}
      if activity.activity_status == Activity::WARM_UP
        activity_notice = activity.activity_notices.ready.first
        if activity_notice
          hash = DateTimeService.second_to_day_hour_minute(activity.start_at.to_i - Time.now.to_i)
          day, hour = hash['day'], hash['hour']
          activity_notice.summary.to_s.gsub!('{day}天',   day == 0 ? '' : "#{day}天")
          activity_notice.summary.to_s.gsub!('{hour}小时', hour == 0 ? '' : "#{hour}小时")
          activity_notice.summary.to_s.gsub!('{minute}',  hash['minute'].to_s)
        end
      elsif activity.activity_status == Activity::HAS_ENDED
        activity_notice = activity.activity_notices.stopped.first
      elsif activity.activity_status == Activity::UNDER_WAY
        if activity.activity_consumes.count < activity.activity_property.coupon_count
          system_can = (activity.consume_day_allow_count.blank?) || (activity.activity_consumes.created_at_today.count < activity.consume_day_allow_count.to_i)
          if system_can
            user_can = (wx_user) && (wx_user.activity_consumes.where(activity_id: activity.id).count < activity.activity_property.get_limit_count)
            if user_can
              activity_consume = activity.activity_consumes.create(supplier_id: activity.supplier_id, wx_mp_user_id: activity.wx_mp_user_id, wx_user_id: wx_user.id)
              activity_notice = activity.activity_notices.active.first
              if activity_notice
                activity_notice.summary.to_s.gsub!('{code}', activity_consume.code.to_s)
                options[:code] = activity_consume.code.to_s
              end
            else
              return Weixin.respond_text(wx_user.uid, wx_mp_user.uid, activity.activity_property.repeat_draw_msg)
            end
          else
            return Weixin.respond_text(wx_user.uid, wx_mp_user.uid, '今日的优惠券已发完啦')
          end
        else #已发放完毕
          activity_notice = activity.activity_notices.stopped.first
        end
      else
        return Weixin.respond_text(wx_user.uid, wx_mp_user.uid, '活动已结束')
      end
      [activity_notice, options]
    end
  end

  def default_pic_url
    qiniu_image_url(Concerns::ActivityQiniuPicKeys::KEY_MAPS[activity_type_id])
  end

  def pic_url
    qiniu_image_url(qiniu_pic_key) || pic
  end


  private
    def set_default_pic
      if pic_url.blank?
        self.qiniu_pic_key = Concerns::ActivityQiniuPicKeys::KEY_MAPS[activity_type_id]
      end
    end

end
