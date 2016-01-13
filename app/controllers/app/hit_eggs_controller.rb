class App::HitEggsController < App::BaseController
  layout 'app/hit_egg'
  before_filter :block_non_wx_browser, :require_wx_mp_user, :find_activity
  
  def show
    redirect_to mobile_notice_url(msg: '商户正在配置活动中') if @activity.setting?
  end

  def hit_egg
    if @activity.setted? and @activity.activity_status == Activity::UNDER_WAY
      @prize_title = '谢谢参与'
      @prize_type = '谢谢参与'
      logger.info "========活动进行中"
      # 有设置奖品
      if @prizes.count > 0
        #全局设置判断 上线前,已有奖品记录关联插入到lottery_draws表
        lottery_draws = @activity.lottery_draws
        # if lottery_draws
          if @activity.activity_property.day_partake_limit == -1 or lottery_draws.where(user_id: session[:user_id]).today.count < @activity.activity_property.day_partake_limit #每人每天参与次数
            if @activity.activity_property.partake_limit == -1 or lottery_draws.where(user_id: session[:user_id]).count < @activity.activity_property.partake_limit #每人参与总次数
              if @activity.activity_property.day_prize_limit == -1 or lottery_draws.where(user_id: session[:user_id]).today.win.count < @activity.activity_property.day_prize_limit #每人每天中奖次数
                if @activity.activity_property.prize_limit == -1 or lottery_draws.where(user_id: session[:user_id]).win.count < @activity.activity_property.prize_limit #每人总中奖次数
                  prize = @activity.get_prize #获取奖品

                  if prize #如果中奖
                    logger.info "========获取到奖券==========="
                    if prize.people_day_limit_count == -1 or lottery_draws.where(user_id: session[:user_id], activity_prize_id: prize.id).today.count < prize.people_day_limit_count # 某奖品每人每天次数
                      if prize.people_limit_count == -1 or lottery_draws.where(user_id: session[:user_id], activity_prize_id: prize.id).count < prize.people_limit_count # 某奖品每人总次数
                        if prize.day_limit_count == -1 or lottery_draws.where(activity_prize_id: prize.id).today.count < prize.day_limit_count # 某奖品当天次数
                                                                                                                                               #出奖次数未超过设置值
                          if lottery_draws.where(activity_prize_id: prize.id).count < prize.prize_count # 奖品数量 如果奖池中还有奖品
                            logger.info "========生成奖品记录,奖品为#{prize.title}============="
                            @activity_consume = prize.activity_consumes.create(site_id: @activity.site_id, activity_id: @activity.id, user_id: session[:user_id])
                            @prize_title = prize.title;  @prize_type = prize.title; @sn_code = @activity_consume.code;
                            lottery_draw = @activity.lottery_draws.create(site_id: @activity.site_id, user_id: session[:user_id], activity_prize_id:  prize.id, status:1 )
                            render 'success.js'
                            return
                          else
                              @error_msg = "没有奖品了"
                            logger.info "========奖池中没有奖品了"
                          end # end 生成奖品
                        else
                          @error_msg = "未中奖"
                          logger.info "========今天此奖品已抽完,不能再中此奖了"
                        end # 当天次数
                      else
                        @error_msg = "未中奖"
                        logger.info "========用户抽中\"#{prize.title}\"的总次数达上限,不能再中此奖了"
                      end # 每人总次数
                    else
                      @error_msg = "未中奖"
                      logger.info "========用户每天抽中\"#{prize.title}\"的次数达上限,今天不能再中此奖了"
                    end # 每人每天次数

                  else
                    @error_msg = "未中奖"
                    logger.info "========未中奖"
                  end # end 中奖
                else
                  @error_msg = "中奖次数已用完"
                  logger.info "========用户总的中奖次数达上限,不能再中奖了"
                end #每人总中奖次数
              else
                @error_msg = "明天再来"
                logger.info "========用户今天总的中奖次数达上限,不能再中奖了"
              end #每人每天中奖次数

              lottery_draw = @activity.lottery_draws.create(site_id: @activity.site_id, user_id: session[:user_id], status: 0) if session[:user_id]
              
              logger.info "========砸金蛋返回失败页面"
              
              render 'faild.js'
              return
            else
              logger.info "参与次数已用完"
              @error_msg = '参与次数已用完'
            end #每人参与总次数
          else
            logger.info "明天再来"
            @error_msg = '明天再来'
            #render :js => "alert('您今天的刮奖次数已用完，谢谢！');"
          end #每人每天参与次数
        # end #end lottery_draws
      else
        logger.info "========没有设置奖品======"
        @error_msg = '没有设置奖品，请与管理员联系'
      end
    end   # activity end
  end

  def create_activity_consume
    @activity_consume = ActivityConsume.find(params[:activity_consume][:id])
    @activity_consume.update_attribute("mobile", params[:activity_consume][:mobile])
    @activity_consume.auto_use_point_prize_consume!
    #redirect_to my_prize_app_hit_eggs_path
    flash[:notice] = "提交成功"
    redirect_to app_hit_egg_path(@activity)
  rescue
    redirect_to mobile_notice_url(msg: '数据错误')
  end

  def get_prize
    @activity_consume = ActivityConsume.find(params[:acid])
  rescue
    redirect_to mobile_notice_url(msg: '数据错误')
  end

  private
    def find_activity
      @activity = Activity.hit_egg.where(id: params[:aid]).first
      if @activity
        @prizes = @activity.activity_prizes
        @activity_consumes = @activity.activity_consumes.where(user_id: session[:user_id]) rescue []
      else
        redirect_to mobile_notice_url(msg: '活动不存在')
      end
    end

end
