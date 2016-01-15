class App::FightController < App::BaseController
  before_filter :block_non_wx_browser

  layout 'app/fight'

  def index
    @activity = @site.activities.fight.find(params[:aid])
    if !@activity.deleted?
      if @site.users.where(id: session[:user_id]).first
        @activity_notice = @activity.activity_notices.where(id: params[:anid]).first
        @share_title = @activity_notice.title
        @share_desc = @activity_notice.summary.try(:squish)
        @share_image = @activity_notice.pic_url

        if @activity_notice and @activity.activity_type.fight?
          logger.info "test log: ready go ..."
          if @activity.activity_status == Activity::UNDER_WAY
             logger.info "test log: 活动进行中...UNDER_WAY"
             @fight_report_card = @activity.fight_report_cards.where(site_id: @activity.site_id, user_id: session[:user_id]).first_or_create

             if "start".eql?(params[:m])
               logger.info "test log: m=>start update fight status to start ..."
               @fight_report_card = @activity.fight_report_cards.find(@fight_report_card.id) if start_fight!
             elsif "register".eql?(params[:m])
               logger.info "test log: m=>register user sign up activity ..."
               if params[:name].present? and params[:mobile].present?
                 Activity.transaction do
                   activity_user = @activity.activity_users.where(site_id: @activity.site_id, user_id: session[:user_id]).first_or_create(name: params[:name], mobile: params[:mobile])
                   @fight_report_card = @activity.fight_report_cards.find(@fight_report_card.id) if activity_user and register_fight!(activity_user.id)
                 end
               end
             end

             if @fight_report_card.unstart?
               logger.info "test log: fight status is unstart, go to index ..."
               render 'index'
             elsif @fight_report_card.started?
               logger.info "test log: fight status is started, go to register ..."
               last_user_info = @activity.activity_users.where(user_id: session[:user_id]).order('created_at desc').first
               @activity_user = @activity.activity_users.new
               if last_user_info
                 @activity_user.name = last_user_info.name
                 @activity_user.mobile = last_user_info.mobile
               end
               render 'register'
             elsif @fight_report_card.registered?
               logger.info "test log: fight status is registered then..."
               @fight_paper = @activity.fight_papers.where(active_date: Date.today).first

               #根据答题情况进行处理
               if( "read".eql?(params[:m]))
                 logger.info "\t m=>#{params[:m]} go to read before fight..."
                 render 'read'
               elsif "question".eql?(params[:m])
                 logger.info "\t m=>#{params[:m]} 答题 to get a question..."
                 get_question(params)
                 if @question
                   render 'answer'
                 else
                   logger.info 'no question to result..'
                   load_rankings
                   render 'result'
                 end
               elsif( "answer".eql?(params[:m]))
                 logger.info "\t m=>answer post answer response json..."
                 @fight_answer = answer! (params)
                 respond_to do |format|
                   format.json { render json: {correct_answer: @fight_answer.correct_answer }}
                 end
               elsif( "result".eql?(params[:m]))
                 logger.info "\t m=>#{params[:m]} 答题 go to show reporte cards..."
                 load_rankings
                 render 'result'
               else
                 # index or register
                 logger.info "\t m=>#{params[:m]} ..."
                 #当前用户当天未参赛
                 if ( ("register".eql?(params[:m]) and @fight_paper.fight_answers.where(user_id: session[:user_id]).count == 0 ) or (@fight_paper.fight_answers.where(user_id: session[:user_id]).count == 0 and @fight_paper.fight_paper_questions.count > 0) )
                   render 'read'
                 else
                   get_question(params)
                   if @question
                     render 'answer'
                   else
                     logger.info 'no question to result..'
                     load_rankings
                     render 'result'
                   end
                 end
               end
             else
               logger.info "none status"
               redirect_to mobile_notice_url(msg: '未知的活动参与状态')
             end
          elsif @activity.activity_status == Activity::SHOW_LIST
             logger.info "test log: 活动榜单公示期...SHOW_LIST"
             @fight_report_card = @activity.fight_report_cards.where(site_id: @activity.site_id, user_id: session[:user_id]).first_or_create
             if @fight_report_card.registered?
               if( "consume".eql?(params[:m]))
                 if( request.post? )
                   logger.info "\t m=>#{params[:m]} 答题 to get a SN for win the fight..."
                   sn = set_consume! ( params )
                   respond_to do |format|
                     format.json { render json: {sn: sn, is_error: sn.blank? ? true : false}}
                   end
                 else
                   respond_to do |format|
                     format.json { render json: {sn: '', is_error: true }}
                   end
                 end
               else
                 load_rankings
                 render 'result'
               end
             else
               #@fight_report_card = @activity.fight_report_cards.new(site_id: @activity.site_id, user_id: session[:user_id])
               load_rankings
               render 'result'
               #render text: '活动已过期'
             end
          elsif @activity.activity_status == Activity::NOT_START
            logger.info "test log: @activity.activity_status=#{@activity.activity_status}"
            redirect_to mobile_notice_url(msg: '活动未开始')
          else
            logger.info "test log: @activity.activity_status=#{@activity.activity_status}"
            redirect_to mobile_notice_url(msg: '活动已过期')
          end
        else
          redirect_to mobile_notice_url(msg: '消息错误或者活动类型错误')
        end
      else
        #render text: '对不起,您无权访问此页面!'
        #redirect_to mobile_unknown_identity_url(@activity.site_id, aid: session[:activity_id])
      end
    else
      redirect_to mobile_notice_url(msg: '活动不存在')
    end
  rescue => error
    logger.info error
    redirect_to mobile_notice_url(msg: '对不起,出现未知错误')
  end

  private
  def start_fight!
    @fight_report_card.update_attributes(status: FightReportCard::STARTED) if @fight_report_card.unstart?
  end

  def register_fight! (activity_user_id)
    @fight_report_card.update_attributes(status: FightReportCard::REGISTERED, activity_user_id: activity_user_id)
  end

  def answer! params
    attrs = { fight_paper_question_id: params[:fight_paper_question_id], activity_id: params[:aid], user_id: session[:user_id], the_day: @fight_paper.the_day }
    answer = @fight_paper.fight_answers.where(attrs).first
    return answer if answer
    fight_question = @fight_paper.fight_questions.find(params[:question_id])
    if params[:user_answer].present? and fight_question.correct_answer.eql?(params[:user_answer])
      @fight_report_card.score += @activity.activity_property.question_score
    end
    @fight_report_card.speed += params[:speed].to_i
    @fight_report_card.update_attributes(score: @fight_report_card.score, speed: @fight_report_card.speed)

    fight_paper_question = @fight_paper.fight_paper_questions.find params[:fight_paper_question_id]
    fight_paper_question.fight_answers.create( attrs.merge(user_answer: params[:user_answer], correct_answer: fight_question.correct_answer, score: @activity.activity_property.question_score, speed: params[:speed]) )
  end

  def get_question params
    answered_question_ids = []
    @fight_paper.fight_answers.where(user_id: session[:user_id]).select(:fight_paper_question_id).each {|fa| answered_question_ids.push(fa.fight_paper_question_id)}

    @answered_questions_count = answered_question_ids.count+1
    fight_paper_questions_count = @fight_paper.fight_paper_questions.count

    @no_question = false
    @is_last_question = false

    if fight_paper_questions_count == 0
      @no_question = true if "question".eql?(params[:m])
    elsif @answered_questions_count == 1 and fight_paper_questions_count > 0
      @question = @fight_paper.fight_paper_questions.order('rand()').first
    elsif @answered_questions_count > 1 and @answered_questions_count <= fight_paper_questions_count
      @question = @fight_paper.fight_paper_questions.where("id not in (?)",answered_question_ids).order('rand()').first
      @is_last_question = true if(fight_paper_questions_count == @answered_questions_count)
    else
      logger.info " @answered_questions_count > fight_paper_questions_count "
    end
  end

  def load_rankings
    @top_rankings = @activity.fight_report_cards.registered.order("fight_report_cards.score desc, fight_report_cards.speed asc").limit(10)
    #@my_ranking = @activity.fight_report_cards.registered.where("fight_report_cards.score >= ? and fight_report_cards.speed >= ?", @fight_report_card.score, @fight_report_card.speed).count
    if @fight_report_card.registered?
      @my_ranking = @activity.fight_report_cards.registered.where("fight_report_cards.score > ?", @fight_report_card.score).count
      same_ranking = 0
      if @fight_report_card.speed == 0
        same_ranking = @activity.fight_report_cards.registered.where("fight_report_cards.score = ?", @fight_report_card.score).count
      else
        same_ranking = @activity.fight_report_cards.registered.where("fight_report_cards.score = ? and fight_report_cards.speed <= ?", @fight_report_card.score, @fight_report_card.speed).count
      end
      @my_ranking += same_ranking
    else
      @my_ranking = -1
    end
    total_fight_report_cards = @activity.fight_report_cards.registered.count
    @defeated_rate = (@my_ranking == 1 ? 100 : (total_fight_report_cards-@my_ranking)/total_fight_report_cards.to_f*100)
    if @activity.activity_status == Activity::SHOW_LIST
      @is_win = false
      prize_count = @activity.activity_prizes.sum(:prize_count)
      if(@my_ranking > 0 and @my_ranking <= prize_count)
        @is_win = true
        if(@fight_report_card.unwin?)
          temp = 0
          @activity.activity_prizes.order(:id).each do |prize|
            if prize.prize_count + temp >= @my_ranking
              @fight_report_card.activity_prize
              set_prize!( @fight_report_card, prize )
              break
            else
              temp += prize.prize_count
            end
          end
        end
      end
    end
  end

  def set_prize! (fight_report_card, prize)
    fight_report_card.update_attributes(win_status: FightReportCard::WINED, activity_prize_id: prize.id)
  end

  def set_consume! params
    sn = ''
    if @fight_report_card.wined? and @fight_report_card.activity_prize
      @activity.transaction do
        activity_consume = @activity.activity_consumes.where(site_id: @activity.site_id, user_id: session[:user_id],activity_prize_id: @fight_report_card.activity_prize.id).first_or_create(mobile: @fight_report_card.activity_user.try(:mobile))
        if activity_consume
          @fight_report_card.update_attributes(win_status: FightReportCard::DRAWED, activity_consume_id: activity_consume.id)
          @fight_report_card.activity_consume = activity_consume
          sn = activity_consume.code
        end
      end
    end
    sn
  end

end
