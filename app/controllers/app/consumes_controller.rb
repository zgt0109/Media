module App
  class ConsumesController < BaseController
    before_filter :block_non_wx_browser

    def show
      @activity = @wx_mp_user.activities.old_coupon.find params[:aid]
      @activity_notice = @activity.activity_notices.find params[:anid]

      filter_for_user
    end

    def filter_for_user
      return unless session[:user_id]
      activity = Activity.where(id: params[:aid]).first
      return unless activity

      if activity.try(:setted?)
        if activity.activity_status == Activity::WARM_UP
          @activity_notice = activity.activity_notices.ready.first
        elsif activity.finished?
          @activity_notice = activity.activity_notices.stopped.first
        elsif activity.activity_status == Activity::UNDER_WAY
          if activity.activity_consumes.count < activity.activity_property.coupon_count
            system_can = (activity.consume_day_allow_count.nil?) || (activity.activity_consumes.created_at_today.count < activity.consume_day_allow_count.to_i)
            if system_can
              user = activity.site.users.where(id: session[:user_id]).first
              user_can = (user) && (user.activity_consumes.where(activity_id: activity.id).count < activity.activity_property.get_limit_count)
              if user_can
                # create a activity_consume
                activity_consume = activity.activity_consumes.create!(site_id: activity.site_id, user_id: user.id)
                params[:code] = activity_consume.code
                @activity_notice = activity.activity_notices.active.first
              else
                @error_notice = '优惠券已发放完毕'
              end
            else
              @error_notice = '今日的优惠券已发完啦'
            end
          else #已发放完毕
            #@activity_notice = activity.activity_notices.stopped.first
            @error_notice = '优惠券已发放完毕'
          end
        else
          @activity_notice = activity.activity_notices.stopped.first
        end
      elsif activity.finished?
        @activity_notice = activity.activity_notices.stopped.first
      elsif activity.setting?
        @error_notice = '活动还未开始'
      else
        @error_notice = '活动不存在'
      end
    end

  end
end
