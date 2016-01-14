class App::GuaController < App::BaseController
  before_filter :block_non_wx_browser

  def show
    @activity_notice = ActivityNotice.where(id: params[:anid]).first
    @activity = @site.activities.gua.find_by_id(params[:id]) || @activity_notice.try(:activity)
    return render_404 unless @activity

    @share_image = @activity_notice.try(:pic_url)
    if @activity.activity_status == Activity::UNDER_WAY
      render 'gua'
    else
      render 'gua_detail'
    end
  end

  def gua
    @activity = Activity.gua.find(params[:aid])
    @share_image = @activity.activity_notices.active.first.try(:pic_url)
    if @activity.setted? && @activity.activity_status == Activity::UNDER_WAY
      @prize_title = @activity.activity_property.no_prize_titles.sample || '谢谢参与'
      @prize_type = @prize_title
      @sn_code = ''
      @is_win = false
      @activity_consume_id = 0
      if params[:source].present? && params[:source].eql?('notice')
        #全局设置判断 上线前,已有奖品记录关联插入到lottery_draws表
        lottery_draws = @activity.lottery_draws
        if lottery_draws
          if @activity.activity_property.day_partake_limit == -1 || lottery_draws.where(user_id: session[:user_id]).today.count < @activity.activity_property.day_partake_limit #每人每天参与次数
            if @activity.activity_property.partake_limit == -1 || lottery_draws.where(user_id: session[:user_id]).count < @activity.activity_property.partake_limit #每人参与总次数
              if @activity.activity_property.day_prize_limit == -1 || lottery_draws.where(user_id: session[:user_id]).today.win.count < @activity.activity_property.day_prize_limit #每人每天中奖次数
                if @activity.activity_property.prize_limit == -1 || lottery_draws.where(user_id: session[:user_id]).win.count < @activity.activity_property.prize_limit #每人总中奖次数
                  prize = @activity.get_prize #获取奖品

                  if prize #如果中奖
                    logger.info "========获取到奖券"
                    if prize.people_day_limit_count == -1 || lottery_draws.where(user_id: session[:user_id], activity_prize_id: prize.id).today.count < prize.people_day_limit_count # 某奖品每人每天次数
                      if prize.people_limit_count == -1 || lottery_draws.where(user_id: session[:user_id], activity_prize_id: prize.id).count < prize.people_limit_count # 某奖品每人总次数
                        if prize.day_limit_count == -1 || lottery_draws.where(activity_prize_id: prize.id).today.count < prize.day_limit_count # 某奖品当天次数
                          #出奖次数未超过设置值
                          if lottery_draws.where(activity_prize_id: prize.id).count < prize.prize_count # 奖品数量 如果奖池中还有奖品
                            logger.info "========生成奖品记录"
                            activity_consume = prize.activity_consumes.create(site_id: @activity.site_id, activity_id: @activity.id, user_id: session[:user_id])
                            @prize_title = prize.title
                            @prize_type = prize.title
                            @sn_code = activity_consume.code
                            @is_win = true
                            @activity_consume_id = activity_consume.id
                          else
                            @error_msg = "奖池中没有奖品了"
                            logger.info "========奖池中没有奖品了"
                          end # end 生成奖品
                        else
                          @error_msg = "今天此奖品已抽完"
                          logger.info "========今天此奖品已抽完"
                        end # 当天次数
                      else
                        @error_msg = "抽中\"#{prize.title}\"的总次数达上限,不能再中此奖了"
                        logger.info "========抽中\"#{prize.title}\"的总次数达上限,不能再中此奖了"
                      end # 每人总次数
                    else
                      @error_msg = "每天抽中\"#{prize.title}\"的次数达上限,今天不能再中此奖了"
                      logger.info "========每天抽中\"#{prize.title}\"的次数达上限,今天不能再中此奖了"
                    end # 每人每天次数

                  else
                    @error_msg = '未中奖'
                    logger.info "========未中奖"
                  end # end 中奖
                else
                  @error_msg = '总中奖次数达上限,不能再中奖了'
                  logger.info "========总中奖次数达上限,不能再中奖了"
                end #每人总中奖次数
              else
                @error_msg = '今天中奖次数达上限,不能再中奖了'
                logger.info "========今天中奖次数达上限,不能再中奖了"
              end #每人每天中奖次数
              lottery_draw = @activity.lottery_draws.create(site_id: @activity.site_id, user_id: session[:user_id], activity_prize_id: (@is_win ? (prize ? prize.id : nil) : nil), status: (@is_win ? LotteryDraw::WIN : LotteryDraw::UNWIN) ) if session[:user_id]
            else
              logger.info "========参与总次数达上限,不能再抽奖了"
              @error_msg = '您的刮奖次数已用完，谢谢！'
            end #每人参与总次数
          else
            logger.info "========今天参与次数达上限,不能再抽奖了"
            @error_msg = '您今天的刮奖次数已用完，谢谢！'
          end #每人每天参与次数
        end #end lottery_draws
      end
    else
      redirect_to mobile_notice_url(msg: '活动不存在')
    end
  end

  def gua_list
    @activity = Activity.find(params[:aid])
    @share_image = @activity.activity_notices.active.first.try(:pic_url)
    user = @site.users.find_by_id(session[:user_id])
    @activity_consumes = user ? user.activity_consumes.includes(:activity_prize).where(activity_id: session[:activity_id]).order("created_at DESC") : []
  end

  def draw_prize
    activity_consume = ActivityConsume.where(id: params[:acid], user_id: session[:user_id]).first
    if activity_consume && activity_consume.update_attributes(mobile: params[:mobile])
      activity_consume.auto_use_point_prize_consume!
      render json: {status: 1}
    else
      render json: {status: 0}
    end
  end

  private

  def gua_prize
    #刮奖活动尚在进行中
    if @activity.setted? && @activity.activity_status == Activity::UNDER_WAY
      #全局设置判断
      #获取奖品
      prize = @activity.get_prize
      if prize #如果中奖
        #如果奖池中还有奖品 出奖次数未超过设置值
        if prize.activity_consumes.count < prize.prize_count && (prize.limit_count == -1 || prize.activity_consumes.count < prize.limit_count)
          activity_consume = prize.activity_consumes.create(site_id: @activity.site_id, activity_id: @activity.id, user_id: session[:user_id])
          @prize_title = prize.title
          @prize_type = prize.title
          @sn_code = activity_consume.code
          @is_win = true
          @activity_consume_id = activity_consume.id
        end
      end
    end
  end

end
