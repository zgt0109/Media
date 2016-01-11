class Mobile::WavesController < Mobile::BaseController
  layout 'mobile/wave'
  before_filter :block_non_wx_browser, :set_activity

  def index
    session[:simulate] = params[:simulate].presence || "blank"
    @error_msg = nil
    if @activity.setted? && @activity.activity_status == Activity::UNDER_WAY
      render 'index'
    elsif  @activity.activity_status == Activity::HAS_ENDED
      render 'has_end'
    elsif  @activity.activity_status == Activity::WARM_UP
      render 'prepare'
    end
  end

  def intro
  end

  def check
    wx_user_lottery_draws = @activity.lottery_draws.where(user_id: session[:user_id])
    if (@activity.activity_property.day_partake_limit == -1) || (wx_user_lottery_draws.today.count < @activity.activity_property.day_partake_limit) #每人每天参与次数
      if (@activity.activity_property.partake_limit == -1) || (wx_user_lottery_draws.count < @activity.activity_property.partake_limit)#每人参与总次数
        if @activity.activity_property.prize_limit == -1 or wx_user_lottery_draws.win.count < @activity.activity_property.prize_limit #每人总中奖次数
          if @activity.activity_property.day_prize_limit == -1 or wx_user_lottery_draws.today.win.count < @activity.activity_property.day_prize_limit #每人每天中奖次数
          else
            return render json: { error_msg: "明天再来" }
          end
        else
          return render json: { error_msg: "您的中奖次数已用完" }
        end
      else
        return render json: { error_msg: "您的参与次数已用完" }
      end
    else
      return render json: { error_msg: "明天再来" }
    end
    render json: {}
  end

  def get_prize
    user_id = session[:user_id]
    if @activity.setted? and @activity.activity_status == Activity::UNDER_WAY
      @prize_title = '谢谢参与'
      logger.info "========活动进行中"
      lottery_draws         = @activity.lottery_draws
      wx_user_lottery_draws = lottery_draws.where(user_id: user_id)
      if @activity.activity_property.day_partake_limit == -1 or wx_user_lottery_draws.today.count < @activity.activity_property.day_partake_limit #每人每天参与次数
        if @activity.activity_property.partake_limit == -1 or wx_user_lottery_draws.count < @activity.activity_property.partake_limit #每人参与总次数
          if @activity.activity_property.day_prize_limit == -1 or wx_user_lottery_draws.today.win.count < @activity.activity_property.day_prize_limit #每人每天中奖次数
            if @activity.activity_property.prize_limit == -1 or wx_user_lottery_draws.win.count < @activity.activity_property.prize_limit #每人总中奖次数
              lottery = @activity.lottery_draws.create(site_id: @activity.site_id, user_id: user_id, status: 0)
              prize   = @activity.get_prize #获取奖品
              if prize #如果中奖.where(user_id: user_id
                logger.info "========获取到奖券==========="
                if prize.people_day_limit_count == -1 or wx_user_lottery_draws.where(activity_prize_id: prize.id).today.count < prize.people_day_limit_count # 某奖品每人每天次数
                  if prize.people_limit_count == -1 or wx_user_lottery_draws.where(activity_prize_id: prize.id).count < prize.people_limit_count # 某奖品每人总次数
                    if prize.day_limit_count == -1 or lottery_draws.where(activity_prize_id: prize.id).today.count < prize.day_limit_count # 某奖品当天次数
                      if lottery_draws.where(activity_prize_id: prize.id).count < prize.prize_count # 奖品数量 如果奖池中还有奖品
                        logger.info "========生成奖品记录,奖品为#{prize.title}============="
                        @activity_consume = prize.activity_consumes.create(site_id: @activity.site_id, activity_id: @activity.id, user_id: user_id)
                        lottery.update_attributes(status: 1, activity_prize_id: prize.id)
                        render json: { status: prize.sort, prize: prize.redpacket_prize? ? "#{prize.prize_value}元红包" :  prize.title, sn_code: @activity_consume.code, acid: @activity_consume.id }
                      else
                        Rails.logger.warn "-----------------------奖池无奖品"
                        render json: { status: 7 }
                      end
                    else
                      Rails.logger.warn "------------------------奖品当天无次数"
                      render json: { status: 7 }
                    end
                  else
                    Rails.logger.warn "--------------------------奖品每人总次数达到"
                    render json: { status: 7 }
                  end
                else
                  Rails.logger.warn "--------------------------奖品每人每天总次数达到"
                  render json: { status: 7 }
                end
              else
                Rails.logger.warn "--------------------------奖品某人总次数"
                render json: { status: 7 }
              end
            else
              Rails.logger.warn "--------------------------没有中奖"
              render json: { status: 7 }
            end
          else
            #每人每天中奖次数
            Rails.logger.warn "-----------------每人每天中奖次数到达"
            render json: { status: -1 }
          end
        else
          #每人参与总次数
          Rails.logger.warn "-----------------每人参与总次数用完"
          render json: { status: -2 }
        end
      else
        #每人每天参与次数
        Rails.logger.warn "--------------------------明天再来"
        render json: { status: -1 }
      end
    else
      render json: { status: 7 }
    end
  end

  def prizes
    @activity_consumes = @wx_user.present? ? @wx_user.activity_consumes.includes(:activity_prize).where(activity_id: @activity.id).order(:created_at) : []
  end

  def draw_prize
    activity_consume = @activity.activity_consumes.where(id: params[:acid], user_id: session[:user_id]).first
    respond_to do |format|
      if activity_consume and activity_consume.update_attributes(mobile: params[:mobile])
        activity_consume.auto_use_point_prize_consume!
        format.json { render json: {status: 1}}
      else
        format.json { render json: {status: 0}}
      end
    end
  end

  def has_end; end
  def prepare; end

  private
  def set_activity
    @activity =  @site.activities.wave.setted.find_by_id(params[:activity_id]) || @site.activities.wave.setted.find_by_id(session[:activity_id])
    return render_404 unless @activity
    @share_image = @activity.pic_url
    @share_title = @activity.name
    @share_desc = @activity.summary.try(:squish)
  end
end
