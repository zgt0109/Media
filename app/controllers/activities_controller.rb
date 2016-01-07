class ActivitiesController < ApplicationController

  TIME_ERROR_MESSAGE = '活动时间填写不正确，开始时间（如填写）必须大于当前时间，结束时间（如填写）必须大于开始时间'

  before_filter :require_wx_mp_user
  before_filter :set_activity, only: [:show, :edit, :update, :destroy,
                                      :stop, :active, :delete, :unset_delete,
                                      :deal_success, :deal_failed,
                                      :edit_prepare_settings, :edit_start_settings,
                                      :edit_rule_settings, :edit_prize_settings,
                                      :prepare_settings, :start_settings, :rule_settings,
                                      :prize_settings, :vote_items, :vote_form, :edit_group, :show_group, :vote_qrcode, :vote_qrcode_download]
  before_filter :restrict_trial_supplier, only: [:new, :consumes, :report, :new_group]

  def index
    @total_activities = current_user.activities.show.marketing_activities.includes([:wx_mp_user,:activity_type]).order('id DESC')
    @search = @total_activities.search(params[:search])
    @activities = @search.page(params[:page])
  end

  def old_coupons
    search_activities_by_type(ActivityType::CONSUME, false)
  end

  def guas
    search_activities_by_type(ActivityType::GUA, false)
    render :old_coupons
  end

  def wheels
    search_activities_by_type(ActivityType::WHEEL, false)
    render :old_coupons
  end

  def guesses
    @help_anchor = '#nav_180'
    search_activities_by_type(ActivityType::GUESS, false)
    render :old_coupons
  end

  def slots
    search_activities_by_type(ActivityType::SLOT, false)
    render :old_coupons
  end

  def aids
    search_activities_by_type(ActivityType::MICRO_AID, false)
    render :aids
  end

  def waves
    search_activities_by_type(ActivityType::WAVE, false)
    render :old_coupons
  end

  def unfolds
    search_activities_by_type(ActivityType::UNFOLD, false)
    render :old_coupons
  end

  def recommends
    search_activities_by_type(ActivityType::RECOMMEND, false)
    render :old_coupons
  end

  def fights
    search_activities_by_type(ActivityType::FIGHT, false)
  end

  def hit_eggs
    search_activities_by_type(ActivityType::HIT_EGG, false)
    render :old_coupons
  end

  def edit_group
    @current_titles = %w(微团购)
    search_activities_by_type(ActivityType::GROUPS, false)
    render layout: 'biz/group', template: "activities/groups/edit"
  end

  def new_group
    @current_titles = %w(微团购)
    @activity ||= current_user.activities.new(wx_mp_user: current_user.wx_mp_user)
    @activity.activity_type = ActivityType.find(14)
    @activity.activity_property = @activity.build_activity_property(activity_type: @activity.activity_type)
    render layout: 'biz/group', template: "activities/groups/new"
  end

  def show_group
    @current_titles = %w(微团购)
    search_activities_by_type(ActivityType::GROUPS, false)
    render layout: 'biz/group', template: "activities/groups/show"
  end

  def groups
    @current_titles = [{title: "微团购", href: groups_activities_path}, "我的团购"]
    search_activities_by_type(ActivityType::GROUPS, false)
    render layout: 'biz/group'
  end

  def survey
    @activity_type_id = 15
    @activity = if params[:id]
      current_user.activities.where(id: params[:id]).first
    else
      current_user.activities.new(activity_type_id: @activity_type_id, qiniu_pic_key: 'FrUR4000rp69hhv75MXSZTFlp0bZ')
    end
  end

  def surveys
    #search_activities_by_type(ActivityType::SURVEYS, false)
    @activity_type_id = 15
    @total_activities = current_user.activities.show.includes([:wx_mp_user,:activity_type]).where("activities.activity_type_id = 15").order('activities.id DESC')
    case params[:status]
      when '-1'
        @activities = @total_activities.where("((activities.status = 0 or activities.status = 1) and activities.end_at is not null and activities.end_at < '#{Time.now}') or activities.status = -1")
      when '0'
        @activities = @total_activities.where("((activities.status = 0 and activities.start_at is null and (activities.end_at is null or (activities.end_at is not null and activities.end_at > '#{Time.now}'))) or ((activities.status = 0 or activities.status = 1) and activities.start_at is not null and activities.start_at > '#{Time.now}'))")
      when '1'
        @activities = @total_activities.where("(( (activities.status = 0 or activities.status = 1) and (activities.start_at is not null and activities.start_at < '#{Time.now}') and (activities.end_at is null or (activities.end_at is not null and activities.end_at > '#{Time.now}'))) or (activities.status = 1 and activities.start_at is null and (activities.end_at is null or (activities.end_at is not null and activities.end_at > '#{Time.now}'))) )")
      else
        @activities = @total_activities
    end
    @search     = @activities.search(params[:search])
    @activities = @search.page(params[:page])
  end

  def votes
    @total_activities = current_user.activities.show.includes([:wx_mp_user,:activity_type]).where("activities.activity_type_id = 12").order('activities.id DESC')
    case params[:status]
      when '-1'
        @activities = @total_activities.where("((activities.status = -3 or activities.status = 1) and activities.end_at is not null and activities.end_at < '#{Time.now}') or activities.status = -1")
      when '0'
	@activities = @total_activities.where("activities.status = 0")
      when '1'
        #@activities = @total_activities.where("(activities.status = -3 and activities.start_at is not null and activities.start_at < '#{Time.now}' and not activities.end_at < '#{Time.now}') or (activities.status = 1 and activities.end_at is null)")
        @activities = @total_activities.where("(( (activities.status = -3 or activities.status = 1) and (activities.start_at is not null and activities.start_at < '#{Time.now}') and (activities.end_at is null or (activities.end_at is not null and activities.end_at > '#{Time.now}'))) or (activities.status = 1 and activities.start_at is null and (activities.end_at is null or (activities.end_at is not null and activities.end_at > '#{Time.now}'))) )")
      when '-3'
        @activities = @total_activities.where("((activities.status = -3 and activities.start_at is null) or (activities.status = -3 and activities.start_at > '#{Time.now}'))")
      else
        @activities = @total_activities
    end
    @search     = @activities.search(params[:search])
    @activities = @search.page(params[:page])
  end

  def vote_form
    unless @activity
      @activity = current_user.activities.new(activity_type_id: 12, qiniu_pic_key: 'FuVB_Al9UIXQZItrVsXwAMbJXxiX')
      @activity.activity_property = @activity.activity_properties.new(activity_type_id: @activity.activity_type_id)
      @activity.activity_property.activity = @activity
    end
  end

  def vote_items
    @items = @activity.activity_vote_items
  end

  def vote_qrcode
  end

  def vote_qrcode_download
    send_data @activity.vote_qrcode_download(params[:type]), :disposition => 'attachment', :filename=>"vote_#{@activity.id}_#{params[:type]}.jpg"
  end

  def user_data
    @search = current_user.activity_users.includes(:activity).where("activities.activity_type_id = 12 and (activities.status > -2 or activities.status = -3)").order('activity_users.created_at DESC').search(params[:search])
    activity_id = params[:search].to_h["activity_id_eq"].presence
    @activity_users = @search.page(params[:page])

    respond_to do |format|
      format.html{
        if activity_id
          @total_count = @activity_users.total_count
          @total_pages = (@total_count / EXPORTING_COUNT.to_f).ceil
        end
      }
      format.xls{
        if activity_id
          @activity_vote_item_ids = current_user.activities.where(id: activity_id).first.try(:activity_vote_item_ids).to_a
          @activity_users_excel = @search.page(params[:page_exl]).per(EXPORTING_COUNT)
        end
      }
    end
  end

  def diagram
    @activity = current_user.activities.vote.find params[:id]
    @activity_vote_items = @activity.activity_vote_items.sort{|x, y| y.select_count <=> x.select_count}
  end

  def update_vote_items
    @activity = current_user.activities.includes(:activity_vote_items).where("activities.id = ? AND activities.activity_type_id = 12", params[:id]).first
    @activity.activity_vote_items.each do |m|
      m.adjust_votes = params[:activity][:activity_vote_items_attributes].select{|k, v| v['id'].to_i == m.id}.values.first['adjust_votes'].to_i
      m.update_column('adjust_votes', m.adjust_votes) if m.adjust_votes_changed?
    end
    redirect_to :back, notice: "操作成功"
  rescue => error
    redirect_to :back, alert: "操作失败"
  end

  def associated_activities
    @activities = current_user.activities.show.unexpired.where(activity_type_id: params[:activity_type_id])
    render json: {data: @activities}
  end

  def report
    @total = 0
    if (@search_params.nil? || @search_params[:activity_id_eq].nil?) #没有指定活动 id,就是全部活动
      as = current_user.activities.where(activity_type_id: params[:activity_type_id])
      as.each do |a|
        @total += (a.activity_property.try(:coupon_count) || 0)
      end
      @total_activity_consumes = current_user.activity_consumes.where("activity_id in (?)", current_user.activities.where(activity_type_id: params[:activity_type_id]) )

      @activity = as.first

      if @activity.blank?
        # @total = 0
      elsif @activity.old_coupon?
        @total = as.joins(:activity_property).sum('activity_properties.coupon_count')
      elsif @activity.groups?
        @total = current_user.activity_consumes.where("activity_group_id is not null").count
      else
        @total = ActivityPrize.where('activity_id in (?)', as.select(:id)).sum(:prize_count)
      end
    else #指定了activity_id_eq活动id
      @total = Activity.find(@search_params[:activity_id_eq]).activity_property.try(:coupon_count)
      @total_activity_consumes = current_user.activity_consumes.where("activity_id in (?)", Activity.find(@search_params[:activity_id_eq]))

      @activity = current_user.activities.where(id: params[:activity_id_eq]).first
      if @activity.old_coupon?
        @total = @activity.activity_properties.first.try(:coupon_count)
      elsif @activity.groups?
        @total = @activity.activity_consumes.count
      else
        @total = @activity.activity_prizes.sum(:prize_count)
      end
    end


    @search_params = params.slice(:shop_branch_id_eq, :activity_id_eq, :created_at_gteq, :created_at_lteq)
    @activity_type_id = params[:activity_type_id]
    @search = @total_activity_consumes.search(@search_params)
    @ret = @search.all
    #@search是所有的单一结果
    @total_count = @ret.count
    @total_used_count = 0
    @hash = Hash.new { |h, k| h[k] = [] } #{"日期_分店",['a1','a2']}

    @ret.each do |c|
      if c.used?
        @hash[ "#{c.created_at.to_date},#{c.shop_branch.try(:name)}" ] << c
        @total_used_count += 1
      end
    end

  end

  def consumes
    conds = { id: params[:activity_id], activity_type_id: params[:activity_type_id] }.reject { |k, v| v.blank? }
    return redirect_to :back if conds.blank?
    @total                   = @total_count = @total_used_count = 0
    @activity                = current_user.activities.where(conds).first
    @activity_type_id        = ( @activity.try(:activity_type_id) || params[:activity_type_id] ).to_s
    activity_ids             = current_user.activities.where(conds).pluck(:id)

    @total_activity_consumes = ActivityConsume.where(activity_id: activity_ids).includes(:activity).order("activity_consumes.id desc")
    @search                  = @total_activity_consumes.search(params[:search])
    @search.activity_id_eq ||= params[:activity_id]
    @activity_consumes       = @search.page(params[:page])

    @total_count             = @total_activity_consumes.count
    @total_used_count        = @total_activity_consumes.used.count

    if params[:activity_id].present?
      @total = Concerns::ActivityHelper.sn_code_count_for_activity( @activity )
    elsif params[:activity_type_id].present?
      @total = Concerns::ActivityHelper.sn_code_count_for_activity_type( current_user, @activity_type_id, activity_ids )
    end

    respond_to do |format|
      if @activity_type_id.eql?("14")
        @current_titles = [{title: "微团购", href: groups_activities_path}, "SN码管理"]
        format.html { render layout: 'biz/group', template: "activities/groups/consumes" }
      else
        format.html
      end
      format.xls {
        if @activity_type_id.eql?("14")
          options = {
          header_columns: %w(活动名称 SN码 状态 姓名 中奖者手机 数量 抽奖时间 使用时间 门店),
          only: [:activity_name, :code, :status_name,:activity_group_name, :mobile, :activity_group_qty, :created_at, :use_at, :shop_branch_name]
        }
        else
          options = {
          header_columns: %w(活动名称 SN码 状态 中奖奖品 中奖者手机 抽奖时间 使用时间 门店),
          only: [:activity_name, :code, :status_name, :activity_prize_name, :mobile, :created_at, :use_at, :shop_branch_name]
        }
        end
        send_data(@search.page(params[:page_exl]).per(EXPORTING_COUNT).to_xls(options))
      }
    end
  end

=begin
  # 先分页，在排序，多页有问题
  def statistics
    @activity = Activity.find params[:id]
    total_activity_users = @activity.activity_users.order('created_at asc')

    params[:search] ||= {}
    @search = total_activity_users.search(params[:search])
    @activity_users = @search.page(params[:page])

    params[:accepte_status].present? && params[:accepte_status] != "全部" && @activity_users.select! do | user|
      activity_consume = user.activity.activity_consumes.where(wx_user_id: user.wx_user.id).first
      if activity_consume.present?
        if params[:accepte_status] == "已兑奖" && activity_consume.status_text == "已使用" 
          true
        elsif params[:accepte_status] == "未兑奖" && activity_consume.status_text == "未使用" 
          true
        end
      elsif params[:accepte_status] == "未达到"
          true
      else
        false
      end
    end

    @activity_users.sort! do |a, b|
      ranka = @activity.get_rank(a.id).present? ? @activity.get_rank(a.id) : Float::INFINITY
      rankb = @activity.get_rank(b.id).present? ? @activity.get_rank(b.id) : Float::INFINITY

      ranka <=> rankb
    end 

    @activity_type_id = @activity.activity_type_id
  end
=end

  # 自定义分页和搜索
  # 分页部分存在很多缺陷，因为电话号码考虑了兑奖时的电话号码和activity user的电话号码，还有兑奖状态还存在名称转换的问题
  # 有三种解决办法：
  #  1. 是通过排行榜去搜索所有的记录，但是这样速度不可去
  #  2. 用join, 计算points后分组排序:
  #     ActivityUser.joins(:aid_results).group(:id).select(:name).select(:mobile).select('count(aid_results.points) as number').order('number').search(params[:search])
  #  3. 目前采取的策略，就是在某种查询下允许分多页，这样不会影响速度
  def statistics
    page_num = (params[:page] || 1).to_i       # default page num
    page_per = (params[:page_per] || 10).to_i  # default numbers per page

    params[:search] ||= {}
    @activity = Activity.find params[:id]
    @search = @activity.activity_users.order('created_at asc').search(params[:search])

    @activity_users = []

    total_count = @activity.get_ranking_member_count
    selected_count = 0
    page_index = 0 # 从第一页开始
    count_in_page = 0
    start = 0      # 搜索偏移必须为零

    if (params[:accepte_status].blank? || params[:accepte_status] == "全部") && params[:search][:wx_user_nickname_like].blank? && params[:search][:mobile_like].blank? # 无查询条件
      start = (page_num -1) * page_per
      ranking_list = @activity.get_ranking_list(page_per, start)

      @activity_users = ranking_list.map do |member|
        @activity.activity_users.find_by_id member[0].to_i
      end
    else # 有查询条件
      while (selected_count < page_per) && (start < total_count) && (page_index < page_num) do # 有查询条件
        ranking_list = @activity.get_ranking_list(page_per, start)

        ranking_users = ranking_list.map do |member|
          @activity.activity_users.find_by_id member[0].to_i
        end

        start += page_per

        params[:accepte_status].present? && params[:accepte_status] != "全部" && ranking_users.select! do |user|
          activity_consume = user.activity.activity_consumes.where(wx_user_id: user.wx_user.id).first
          if activity_consume.present?
            if params[:accepte_status] == "已兑奖" && (activity_consume.used? || activity_consume.auto_used?) 
              true
            elsif params[:accepte_status] == "未兑奖" && activity_consume.unused?
              true
            end
          elsif params[:accepte_status] == "未达到"
            true
          else
            false
          end
        end

        params[:search][:wx_user_nickname_like].present? && ranking_users.select! do |user|
          user.try(:wx_user).try(:nickname).try(:match, params[:search][:wx_user_nickname_like])
        end

        params[:search][:mobile_like].present? && ranking_users.select! do |user|
          activity_consume = user.activity.activity_consumes.where(wx_user_id: user.wx_user.id).first
          activity_consume.try(:mobile).try(:match, params[:search][:mobile_like]) || user.try(:mobile).try(:match, params[:search][:mobile_like])
        end

        ranking_users.each do |user|
          if page_index == (page_num - 1) # 当前页
            @activity_users << user
            selected_count += 1
            page_index += 1 if selected_count >= page_per
          else
            count_in_page += 1
            if count_in_page >= page_per
              page_index += 1
              count_in_page = 0
            end
          end
        end
      end
    end

    search_count = @search.count
    search_count = (search_count == 0) ? total_count : search_count
    @activity_users = Kaminari.paginate_array(@activity_users, total_count: search_count).page(page_num).per(page_per)

    @activity_type_id = @activity.activity_type_id
  end

  def new
    @activity = current_user.activities.new( ready_at: 10.minutes.since ) unless @activity_type
    @activity.activity_type_id = @activity_type || params[:activity_type] || 3
    if @activity.fight? && !@activity_type
      @activity.active_activity_notice = @activity.activity_notices.new(wx_mp_user_id: current_user.wx_mp_user.id, title: '活动名称', pic: File.open(Rails.root.to_s+"/app/assets/images/activity_pics/8.jpg"), summary: "亲，请点击进入一战到底答题页面，快来参加活动吧！", activity_status: 1 )
      @activity.activity_property = @activity.activity_properties.new(activity_type_id: @activity.activity_type_id)
      @activity.activity_property.activity = @activity
      %w(一等奖 二等奖 三等奖).each do |title|
        @activity.activity_prizes.new(title: title, can_validate: true)
      end
      return render :fight_form
    end
    @activity_type_id = @activity.activity_type_id
    # @activity.activity_notices = ActivityNotice.notices_for(@activity_type_id)
    # logger.info @activity.activity_notices
    if @activity.old_coupon?
      @activity.ready_activity_notice = ActivityNotice.coupon_ready_notice
      return render "old_coupons/form"
    elsif @activity.gua? || @activity.wheel? || @activity.hit_egg?
      @activity.ready_activity_notice = ActivityNotice.new_ready_notice_by_type(@activity.activity_type_id)
      return render "guas/form"
    elsif @activity.guess?
      return render "huodong/guesses/form"
    end

    if @activity.vote? || @activity.surveys?
      render layout: 'application_pop'
    else
      render layout: 'application_gm'
    end
  end

  def prepare_settings
    if (@activity.new_record? and activity_time_invalid?) and !@activity.fight?
      redirect_to :back, notice: TIME_ERROR_MESSAGE
    else
      @activity.attributes = params[:activity]
      if @activity.save
        redirect_to edit_start_settings_activity_path(@activity)
      else
        redirect_to :back, alert: "保存失败: #{@activity.errors.full_messages.join('，')}"
      end
    end
  rescue => error
    redirect_to :back, alert: "保存失败"
  end

  def start_settings
    if (@activity.new_record? and activity_time_invalid?) and !@activity.fight?
      redirect_to :back, notice: TIME_ERROR_MESSAGE
    else
      @activity.attributes = params[:activity]
      if @activity.save
        redirect_to edit_rule_settings_activity_path(@activity)
      else
        redirect_to :back, alert: "保存失败: #{@activity.errors.full_messages.join('，')}"
      end
    end
  rescue => error
    redirect_to :back, alert: "保存失败"
  end

  def rule_settings
    elements = params[:activity_element_ids].in_groups_of(3)
    prize = ActivityPrize.find_by_id(params[:prize_id])
    new_activity_elements= []
    params[:activity][:activity_prizes_attributes].each_with_index do |rule, index|
      if params[:prize_id] == rule.last.fetch(:id)
        new_activity_elements = elements[index]
      end
    end
    new_activity_element_ids = new_activity_elements.join(',')
    if new_activity_elements.count == 3 && prize.activity.activity_prizes.pluck(:activity_element_ids).include?(new_activity_element_ids)
      return redirect_to :back, notice: '奖项设置不能重复'
    else
      prize.activity_element_ids = new_activity_element_ids
      prize.save(validate: false)
      return redirect_to :back
    end
  end

  def prize_settings
    @activity.status = Activity::SETTED if @activity.setting? and !@activity.fight?
    @activity.attributes = params[:activity]
    if @activity.save
      redirect_to slots_activities_path
    else
      redirect_to :back, alert: "保存失败: #{@activity.errors.full_messages.join('，')}"
    end
  rescue => error
    redirect_to :back, notice: "保存失败"
  end

  def edit_settings
    @activity_type_id = @activity.activity_type_id
    render layout: 'application_gm'
  end
  alias edit_prepare_settings edit_settings
  alias edit_start_settings   edit_settings
  alias edit_rule_settings    edit_settings


  def edit_prize_settings
    return redirect_to :back, alert: '中奖设置不完整' if @activity.activity_prizes.emtpy_element_ids.count > 0
    exists_element_ids = @activity.activity_prizes.pluck(:activity_element_ids).flatten.uniq
    prize_has_nil_elements = exists_element_ids.include?(nil)
    prize_has_blank_elements = exists_element_ids.reject(&:blank?).map{|ids| ids.split(',') }.include?('')
    if prize_has_nil_elements || prize_has_blank_elements
      return redirect_to :back, alert: '中奖设置不完整'
    end
    @activity_type_id = @activity.activity_type_id
    render layout: 'application_gm'
  end

  def create
    @activity = current_user.activities.new(params[:activity])
    #@activity.extend.closing_note = params[:extend_closing_note] if params[:extend_closing_note].present?
    #@activity.extend.allow_repeat_apply = params[:allow_repeat_apply].to_i
    extend_format
    @activity.activity_type = ActivityType.find_by_id(params[:activity]["activity_type_id"]) rescue nil
    @activity.activity_property ||= @activity.build_activity_property(params[:activity][:activity_property_attributes]) rescue nil
    @activity.activity_property.activity_type ||= @activity.activity_type rescue nil

    @activity.name = @activity.active_activity_notice.title if @activity.fight?
    @activity_notice = @activity.active_activity_notice
    @activity_type = @activity.activity_type_id

    if params[:extend_show_list_day].present? && params[:extend_show_list_day].to_i <= 0
      flash[:alert] = "榜单公示期必须为整数且大于0"
      return handle_save_failed
    end

    if activity_time_invalid? && (@activity.fight? || @activity.vote? || @activity.surveys?)
      flash[:alert] = TIME_ERROR_MESSAGE
    elsif !@activity.save
      flash[:alert] = "保存失败: #{@activity.errors.full_messages.join('，')}"
    else
      flash[:notice] = '添加成功'
      redirect_to case
      when @activity.fight?         then fight_papers_path({activity_id: @activity.id})
      when @activity.vote?          then vote_items_activity_path(@activity)
      when @activity.surveys?       then activity_survey_questions_url(activity_id: @activity.id)
      when @activity.slot?          then edit_prepare_settings_activity_path(@activity)
      when @activity.car?           then :back
      when @activity.website?       then :back
      when @activity.groups?        then groups_activities_path
      when @activity.panoramagram?  then panoramagrams_path
      when @activity.wx_card?       then wx_cards_path
      when @activity.plot_bulletin? ||
           @activity.plot_repair? ||
           @activity.plot_complain? ||
           @activity.plot_telephone? ||
           @activity.plot_owner? ||
           @activity.plot_life? then wx_plots_url
      else edit_activity_path(@activity)
      end
    end

    if flash[:alert]
      handle_save_failed
    end
  end

  def handle_save_failed
    case
    when @activity.fight?   then render :fight_form
    when @activity.surveys? then render :survey
    when @activity.groups?  then render layout: 'biz/group', template: "activities/groups/new"
    when @activity.vote?    then render :vote_form
    when @activity.car?     then redirect_to :back
    when @activity.website? then redirect_to websites_path
    when @activity.guess?   then render 'huodong/guesses/form'
    when @activity.plot_bulletin? ||
         @activity.plot_repair? ||
         @activity.plot_complain? ||
         @activity.plot_telephone? ||
         @activity.plot_owner? ||
         @activity.plot_life?    then redirect_to :back
    when @activity.ktv_order?    then redirect_to :back
    when @activity.panoramagram? then render 'huodong/panoramagrams/index'
    when @activity.wx_card?      then render 'huodong/wx_cards/index'
    when @activity.coupon?       then render 'biz/coupons/edit_activity'
    else render action: (@activity.new_record? ? 'new' : 'edit')
    end
  end

  def edit
    @activity_type_id = @activity.activity_type_id
    if @activity.vote? || @activity.surveys?
      render layout: 'application_pop'
    elsif @activity.fight?
      render :fight_form
    elsif @activity.old_coupon?
      render "old_coupons/form"
    elsif @activity.gua? || @activity.wheel? || @activity.hit_egg?
      render "guas/form"
    end
  end

  alias show edit

  def extend_format
    return unless @activity
    extent_attrs = params[:activity][:extend].to_h
    %w(allow_show_vote_percent allow_show_vote_count allow_show_user_tel album_watermark_img show_watermark).each do |method_name|
      @activity.extend.send("#{method_name.to_s}=", extent_attrs[method_name])
    end

    %w(tel).each do |method_name|
      @activity.extend.send("#{method_name.to_s}=", extent_attrs[method_name]) if extent_attrs[method_name].present?
    end

    %i(allow_repeat_apply).each do |method_name|
      @activity.extend.send("#{method_name.to_s}=", params[method_name])
    end
    @activity.extend.closing_note = params[:extend_closing_note] if params.keys.include?("extend_closing_note")
    @activity.extend.show_list_day = (params[:extend_show_list_day].presence || 7) if params.keys.include?("extend_show_list_day")
  end

  def update
    if params[:shop_id] && params[:shop]
      shop = Shop.where(id: params[:shop_id]).first
      shop.update_attributes(params[:shop]) if shop
    end

    if params[:extend_show_list_day].present? && params[:extend_show_list_day].to_i <= 0
      flash[:alert] = "榜单公示期必须为整数且大于0"
      return handle_save_failed
    end

    if activity_time_invalid? and !@activity.fight?
      flash[:alert] =  TIME_ERROR_MESSAGE
      handle_save_failed
    else
      total_prize_rate = params[:activity][:activity_prizes_attributes].to_h.sum { |k, v| v[:prize_rate].to_f }
      return render_with_alert 'edit', '保存失败, 中奖几率总和不能大于100%' if total_prize_rate > 100
      @activity.status = Activity::SETTED if @activity.setting? && !@activity.fight? && !@activity.surveys? && !@activity.vote?
      @activity.attributes = params[:activity]
      extend_format
      #@activity.extend.closing_note = params[:extend_closing_note] if params[:extend_closing_note].present?
      #@activity.extend.tel = params[:activity][:extend][:tel] if params[:activity] && params[:activity][:extend] && params[:activity][:extend][:tel]
      #@activity.extend.allow_repeat_apply = params[:allow_repeat_apply].to_i

      @activity.vip_card.show_introduce = (@activity.vip_card.show_introduce.presence || '1').succ if @activity.vip?

      if @activity.save
        flash[:notice] = '保存成功'
        # flash[:notice] = '微官网保存成功，请在账户中心微信扩展-自定义菜单设置中设置使用微官网' if @activity.website? && current_user.bqq_account?
        redirect_to case
        when @activity.surveys?      then surveys_activities_url(status: 'ok')
        when @activity.vote?         then votes_activities_url
        when @activity.groups?       then groups_activities_url
        when @activity.panoramagram? then panoramagrams_path
        when @activity.wx_card?      then wx_cards_path
        when @activity.website?      then
          if current_user.can_show_introduce? && current_user.task0?
            current_user.update_attributes(show_introduce: 1)
            websites_path(task: Time.now.to_i)
          else
            websites_path
          end
        when @activity.plot_related? then wx_plots_url
        else :back
        end
      else
        flash[:alert] =  "保存失败：#{@activity.errors.full_messages.join('，')}"
        handle_save_failed
      end
    end
  end

  def destroy
    @activity.delete_ranking_list if @activity.has_ranking_list?

    redirect_to :back, notice: notice_for( @activity.deleted! )
  end

  def delete
    @activity.delete_ranking_list if @activity.has_ranking_list?

    redirect_to :back, notice: notice_for( @activity.deleted! )
  end

  def stop
    redirect_to :back, notice: notice_for( @activity.stopped! )
  end

  def active
    redirect_to :back, notice: notice_for( @activity.setted! )
  end

  def unset_delete
    redirect_to :back, notice: notice_for( @activity.unset_delete! )
  end

  def deal_failed
    redirect_to :back, notice: notice_for( @activity.deal_failed! )
  end

  def deal_success
    redirect_to :back, notice: notice_for( @activity.deal_success! )
  end

  private
    def set_activity
      @activity = current_user.activities.find params[:id] if params[:id].present?
      if @activity && @activity.old_coupon? && @activity.ready_activity_notice.present?
        @activity.ready_activity_notice.summary = @activity.ready_activity_notice.summary
        day_hour_minute = DateTimeService.second_to_day_hour_minute(@activity.start_at.to_i - Time.now.to_i)
        day_hour_minute['day'] == 0 ? @activity.ready_activity_notice.summary.to_s.gsub!('{day}天', '') :  @activity.ready_activity_notice.summary.to_s.gsub!('{day}', day_hour_minute['day'].to_s)
        day_hour_minute['hour'] == 0 ? @activity.ready_activity_notice.summary.to_s.gsub!('{hour}小时', '') :  @activity.ready_activity_notice.summary.to_s.gsub!('{hour}', day_hour_minute['hour'].to_s)
        @activity.ready_activity_notice.summary.to_s.gsub!('{minute}', day_hour_minute['minute'].to_s)
      end
    end

    def activity_time_valid?
      ready_at, start_at, end_at, activity_type_id = params[:activity].values_at(:ready_at, :start_at, :end_at, :activity_type_id).map(&:presence)
      ready_at, start_at, end_at = [ready_at, start_at, end_at].map{ |t| Time.parse(t) if t }
      if action_name == 'create' # 创建活动时，预热时间、活动开始时间、活动结束时间（如果存在）必须大于当前时间
        unless @activity.groups?
          return false if ready_at && ready_at < Time.now
        end
        return false if start_at && start_at < Time.now
        return false if end_at && end_at < Time.now
      end
      if activity_type_id == '8' # 一战到底必须设置开始时间和结束时间
        return false if start_at.nil? || end_at.nil?
        return false if end_at.to_date - start_at.to_date > 6
      elsif %w[10 12 15].include?(activity_type_id)
        return false if start_at && start_at < Time.now
        return false if end_at && end_at < Time.now
        return start_at < end_at if start_at && end_at
      elsif activity_type_id != '62' && ready_at && start_at && end_at
        return ready_at <= start_at && start_at <= end_at
      end
      return true
    end

    def activity_time_invalid?
      pp 'activity_time_valid?', activity_time_valid?
      !activity_time_valid?
    end

    def search_activities_by_type(activity_type_id, render_index = true)
      @total_activities = current_user.activities.show.includes([:wx_mp_user,:activity_type]).order('activities.id DESC')
      params[:search] ||= {}
      params[:search][:activity_type_id_eq] = activity_type_id
      @search           = @total_activities.search(params[:search])
      @activities       = @search.where(activity_type_id: activity_type_id).page(params[:page])
      @activity_type_id = activity_type_id
      @activity_id = params[:search][:id_eq]
      render 'index' if render_index
    end

    def notice_for( success )
      success ? '操作成功' : '操作失败'
    end

end
