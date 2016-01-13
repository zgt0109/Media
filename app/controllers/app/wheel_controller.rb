module App
  class WheelController < BaseController
    before_filter :block_non_wx_browser, :require_wx_mp_user

    def show
      @main_id = "stage"
      @activity = @wx_mp_user.activities.wheel.show.find(params[:id])
      @activity_notice = @activity.activity_notices.find_by_id(session[:activity_notice_id]) || @activity.activity_notices.active.first

      wx_user = @wx_mp_user.wx_users.where(id: session[:wx_user_id]).first if session[:wx_user_id].present?
      @activity_consumes =  wx_user.present? ? wx_user.activity_consumes.includes(:activity_prize).where(activity_id: params[:aid]) : []
      if @activity 
        @share_image = @activity_notice.try(:pic_url)
        if @activity.setted?  && @activity.activity_status == Activity::UNDER_WAY
          titles = @activity.activity_prizes.pluck(:title)
          @prizes = (titles+titles.reverse).take(6)
          @main_class = "stage"
          render 'index'
        else
          @main_class = @activity.finished? ? "stage stage-end" : "stage stage-start"
          render 'detail'
        end
      else
        redirect_to mobile_notice_url(msg: '活动不存在')
      end
    end

    def list
      @main_id = "stage"
      @main_class = "stage"
      wx_user = @wx_mp_user.wx_users.find_by_id(session[:wx_user_id])
      @activity = Activity.find(params[:aid])
      @share_image = @activity.activity_notices.active.first.try(:pic_url)
      @activity_consumes = wx_user.present? ? wx_user.activity_consumes.includes(:activity_prize).where(activity_id: params[:aid]).order(:created_at) : []
    end

    def prize
      if params[:t].present? and params[:t].eql?('lottery')
        is_thank = false; is_error = true; @is_win = false; @activity_consume_id = ''; @sn_code = ''; level = ''; error_id = ''; error_msg = '对不起，网络连接错误，请重试'
        @activity = Activity.wheel.where(id: params[:aid], wx_mp_user_id: session[:wx_mp_user_id]).first
        if @activity
          logger.info "========活动存在"
          #抽奖活动尚在进行中
          if @activity.setted? and @activity.activity_status == Activity::UNDER_WAY
            logger.info "========活动进行中"

            #全局设置判断 上线前,已有奖品记录关联插入到lottery_draws表
            lottery_draws = @activity.lottery_draws
            if lottery_draws
              if @activity.activity_property.day_partake_limit == -1 or lottery_draws.where(wx_user_id: session[:wx_user_id]).today.count < @activity.activity_property.day_partake_limit #每人每天参与次数
                if @activity.activity_property.partake_limit == -1 or lottery_draws.where(wx_user_id: session[:wx_user_id]).count < @activity.activity_property.partake_limit #每人参与总次数
                  if @activity.activity_property.day_prize_limit == -1 or lottery_draws.where(wx_user_id: session[:wx_user_id]).today.win.count < @activity.activity_property.day_prize_limit #每人每天中奖次数
                    if @activity.activity_property.prize_limit == -1 or lottery_draws.where(wx_user_id: session[:wx_user_id]).win.count < @activity.activity_property.prize_limit #每人总中奖次数
                      prize = @activity.get_prize #获取奖品

                      if prize #如果中奖
                        logger.info "========获取到奖券"
                        if prize.people_day_limit_count == -1 or lottery_draws.where(wx_user_id: session[:wx_user_id], activity_prize_id: prize.id).today.count < prize.people_day_limit_count # 某奖品每人每天次数
                          if prize.people_limit_count == -1 or lottery_draws.where(wx_user_id: session[:wx_user_id], activity_prize_id: prize.id).count < prize.people_limit_count # 某奖品每人总次数
                            if prize.day_limit_count == -1 or lottery_draws.where(activity_prize_id: prize.id).today.count < prize.day_limit_count # 某奖品当天次数
                              #出奖次数未超过设置值
                              if lottery_draws.where(activity_prize_id: prize.id).count < prize.prize_count # 奖品数量 如果奖池中还有奖品
                                logger.info "========生成奖品记录"
                                activity_consume = prize.activity_consumes.create(supplier_id: @activity.supplier_id, wx_mp_user_id: @activity.wx_mp_user_id, activity_id: @activity.id, wx_user_id: session[:wx_user_id])
                                @prize_title = prize.title
                                @prize_type = prize.title
                                @sn_code = activity_consume.code
                                @is_win = true
                                @activity_consume_id = activity_consume.id
                                is_error = false
                                level = prize.level
                              else
                                logger.info "========奖池中没有奖品了"
                                is_error = false
                                is_thank = true
                              end # end 生成奖品
                            else
                              logger.info "========今天此奖品已抽完"
                              is_error = false
                              is_thank = true
                            end # 当天次数
                          else
                            logger.info "========抽中\"#{prize.title}\"的总次数达上限,不能再中此奖了"
                            is_error = false
                            is_thank = true
                          end # 每人总次数
                        else
                          logger.info "========每天抽中\"#{prize.title}\"的次数达上限,今天不能再中此奖了"
                          is_error = false
                          is_thank = true
                        end # 每人每天次数

                      else
                        logger.info "========未中奖"
                        is_error = false
                        is_thank = true
                      end # end 中奖

                    else
                      logger.info "========总中奖次数达上限,不能再中奖了"
                      is_error = false
                      is_thank = true
                    end #每人总中奖次数
                  else
                    logger.info "========今天中奖次数达上限,不能再中奖了"
                    is_error = false
                    is_thank = true
                  end #每人每天中奖次数

                  lottery_draw = @activity.lottery_draws.create(supplier_id: @activity.supplier_id, wx_mp_user_id: @activity.wx_mp_user_id, wx_user_id: session[:wx_user_id], activity_prize_id: (@is_win ? (prize ? prize.id : nil) : nil), status: (@is_win ? LotteryDraw::WIN : LotteryDraw::UNWIN) )

                else
                  logger.info "========参与总次数达上限,不能再抽奖了"
                  error_id = '-999'
                  error_msg = '您的抽奖次数已用完'
                end #每人参与总次数
              else
                logger.info "========今天参与次数达上限,不能再抽奖了"
                error_id = '-999'
                error_msg = '您今天的抽奖次数已用完'
              end #每人每天参与次数

          end #end lottery_draws and lottery_draws.count > 0

          else
            logger.info "========预热/停止/结束"
            error_id = '-103' if @activity.setted? and @activity.activity_status == Activity::WARM_UP
            error_id = '-104' if @activity.stopped?
            error_id = '-401' if @activity.deleted? or (@activity.setted? and @activity.activity_status == Activity::HAS_ENDED)
          end
        end

        respond_to do |format|
          format.json { render json: {ajax_msg: { isthank: is_thank, iserror: is_error, iswin: @is_win, winid: @activity_consume_id, sn: @sn_code, prizeid: level, prize_title: prize.try(:title), errorid: error_id, sn_code: @sn_code, activity_consume_id: @activity_consume_id, errorMsg: error_msg} }}
        end

      elsif params[:t].present? and params[:t].eql?('mobile')
        activity_consume = ActivityConsume.where(id: params[:acid], wx_user_id: session[:wx_user_id]).first
        respond_to do |format|
          logger.info "=====#{params.to_s}"
          if activity_consume and activity_consume.update_attributes(mobile: params[:mobile])
            activity_consume.auto_use_point_prize_consume!
            format.json { render json: {status: 1}}
          else
            format.json { render json: {status: 0}}
          end
        end
      end
    rescue => error
      respond_to do |format|
        if params[:t].present? and params[:t].eql?('lottery')
          is_thank = false; is_error = true; @is_win = false; @activity_consume_id = ''; @sn_code = ''; level = ''; error_id = ''; error_msg = '＝＝！出错啦～'
          format.json { render json: {ajax_msg: { isthank: is_thank, iserror: is_error, iswin: @is_win, winid: @activity_consume_id, sn: @sn_code, prizeid: level, errorid: error_id, sn_code: @sn_code, activity_consume_id: @activity_consume_id, errorMsg: error_msg} }}
        elsif params[:t].present? and params[:t].eql?('mobile')
          format.json { render json: {status: 0}}
        end
      end
    end

  end
end
