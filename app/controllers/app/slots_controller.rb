module App
  class SlotsController < BaseController
    before_filter :block_non_wx_browser, :require_wx_mp_user, :find_activity

    def index
      @slot_prizes_left_count = @activity.slot_prizes_left_count
    end

    def slot
      if @activity.setted? and @activity.activity_status == Activity::UNDER_WAY
        @prize_title = '谢谢参与'
        @prize_type = '谢谢参与'
        logger.info "========活动进行中"
        if @prizes.present? #
          #全局设置判断 上线前,已有奖品记录关联插入到lottery_draws表
          lottery_draws = @activity.lottery_draws
          # if lottery_draws
            if @activity.activity_property.day_partake_limit == -1 or lottery_draws.where(wx_user_id: session[:wx_user_id]).today.count < @activity.activity_property.day_partake_limit #每人每天参与次数
              if @activity.activity_property.partake_limit == -1 or lottery_draws.where(wx_user_id: session[:wx_user_id]).count < @activity.activity_property.partake_limit #每人参与总次数
                if @activity.activity_property.day_prize_limit == -1 or lottery_draws.where(wx_user_id: session[:wx_user_id]).today.win.count < @activity.activity_property.day_prize_limit #每人每天中奖次数
                  if @activity.activity_property.prize_limit == -1 or lottery_draws.where(wx_user_id: session[:wx_user_id]).win.count < @activity.activity_property.prize_limit #每人总中奖次数

                    @activity_element_ids = @activity.generate_slot_element_ids
                    prize = @activity.get_slot_prize(@activity_element_ids) #获取奖品

                    if prize #如果中奖
                      logger.info "========获取到奖券==========="
                      if prize.people_day_limit_count == -1 or lottery_draws.where(wx_user_id: session[:wx_user_id], activity_prize_id: prize.id).today.count < prize.people_day_limit_count # 某奖品每人每天次数
                        if prize.people_limit_count == -1 or lottery_draws.where(wx_user_id: session[:wx_user_id], activity_prize_id: prize.id).count < prize.people_limit_count # 某奖品每人总次数
                          if prize.day_limit_count == -1 or lottery_draws.where(activity_prize_id: prize.id).today.count < prize.day_limit_count # 某奖品当天次数
                                                                                                                                                 #出奖次数未超过设置值
                            if lottery_draws.where(activity_prize_id: prize.id).count < prize.prize_count # 奖品数量 如果奖池中还有奖品
                              logger.info "========生成奖品记录,奖品为#{prize.title}============="
                              @activity_element_ids = @activity_element_ids.split(',').map(&:to_i)
                              @activity_consume = prize.activity_consumes.create(supplier_id: @activity.supplier_id, wx_mp_user_id: @activity.wx_mp_user_id, activity_id: @activity.id, wx_user_id: session[:wx_user_id])
                              @prize_title = prize.title;  @prize_type = prize.title; @sn_code = @activity_consume.code;
                              lottery_draw = @activity.lottery_draws.create(supplier_id: @activity.supplier_id, wx_mp_user_id: @activity.wx_mp_user_id, wx_user_id: session[:wx_user_id], activity_prize_id:  prize.id, status:1 )
                              render 'success.js'
                              return
                            else
                              @activity_element_ids = @activity.generate_rand_slot_element_ids.split(',').map(&:to_i)
                              @fail_reason = '奖池中没有奖品了'
                              logger.info "========奖池中没有奖品了"
                            end # end 生成奖品
                          else
                            @fail_reason = '今天此奖品已抽完'
                            logger.info "========今天此奖品已抽完"
                          end # 当天次数
                        else
                          @fail_reason = '用户抽奖次数已达上限'
                          logger.info "========用户抽奖次数已达上限"
                        end # 每人总次数
                      else
                        @fail_reason = '用户抽奖次数已达上限'
                        logger.info "========用户抽奖次数已达上限"
                      end # 每人每天次数

                    else
                      @fail_reason = '没有中奖, 再来一次'
                      logger.info "========未中奖"
                    end # end 中奖

                  else
                    @fail_reason = '中奖次数已达上限'
                    logger.info "========中奖次数已达上限"
                  end #每人总中奖次数
                else
                  @fail_reason = '今天中奖次数已达上限'
                  logger.info "========今天中奖次数已达上限"
                end #每人每天中奖次数
                @activity_element_ids =  @activity.generate_rand_slot_element_ids.split(',').map(&:to_i)
                lottery_draw = @activity.lottery_draws.create(supplier_id: @activity.supplier_id, wx_mp_user_id: @activity.wx_mp_user_id, wx_user_id: session[:wx_user_id], status: 0)
                render 'fail.js'
                return
              else
                logger.info "========参与总次数达上限,不能再抽奖了"
                @fail_reason = '您的抽奖次数已用完！'
              end #每人参与总次数
            else
              logger.info "========今天参与次数达上限,不能再抽奖了"
              @fail_reason = '您今天抽奖次数已用完！'
              #render :js => "alert('您今天的老虎机次数已用完，谢谢！');"
            end #每人每天参与次数
          # end #end lottery_draws
        else
          logger.info "========没有设置奖品======"
          @fail_reason = '没有设置奖品，请与商家联系'
        end #没有奖品
      end   # activity end
    end

    def create_activity_consume
      @activity_consume = ActivityConsume.find(params[:activity_consume][:id])
      @activity_consume.update_attribute("mobile", params[:activity_consume][:mobile])
      @activity_consume.auto_use_point_prize_consume!
      flash[:notice] = "提交成功"
      redirect_to app_slots_path
    end

    def get_prize
      @activity_consume = ActivityConsume.find(params[:acid])
      respond_to do |format|
        format.js
      end
    end

    private

    def find_activity
      id = params[:activity_id].presence || session[:activity_id].presence
      @activity = Activity.slot.find(id)

      notice = if @activity.activity_status == Activity::WARM_UP
        @activity.activity_notices.ready.first
      else
        @activity.activity_notices.active.first
      end

      @share_image = notice.pic_url
      @share_title = notice.title
      @share_desc = notice.summary.try(:squish)

      @prizes = @activity.activity_prizes.to_a
      @elements = @activity.activity_prize_elements.to_a
      @activity_consumes = @activity.activity_consumes.where(wx_user_id: session[:wx_user_id]).order('id desc') rescue []

      @elements_hash = {}
      @elements.each_with_index {|e, index| @elements_hash[e.id] = index }
    end
  end
end
