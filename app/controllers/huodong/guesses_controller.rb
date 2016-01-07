class Huodong::GuessesController < ApplicationController
  before_filter :set_help_anchor
  before_filter :require_wx_mp_user

  before_filter :find_activity, only: [:show, :edit, :settings, :load_more, :update, :destroy]
  before_filter :set_coupons_and_gifts,  only: [:settings]

  def index
  end

  def edit
  end

  def settings
    @guess = ::Activity::GuessActivity.find_by_id(params[:id])
    @questions = current_user.guess_questions.where("status = ?", Activity::SETTED).limit(9).order('created_at desc')
    @has_more =  current_user.guess_questions.where("status = ? and id < ?", Activity::SETTED, @questions.last.try(:id)).exists?
  end

  def consumes
    sql = "join guess_participations as participation on participation.consume_id = consumes.id join activities as activity on participation.activity_id = activity.id"
    activity_ids = current_user.activities.guess.pluck(:id)
    @total_consumes = current_user.wx_mp_user.consumes.joins(sql).where("activity.id in (?)", activity_ids)
    if params[:activity_id].present?
      activity_ids =  [params[:activity_id]]
      @consumes = @total_consumes.where("activity.id in (?)", activity_ids)
    else
      @consumes = @total_consumes
    end

    @consumes = @consumes.where(code: params[:code]) if params[:code].present?

    @total = ::Activity::GuessActivity.where(supplier_id: current_user.id).map(&:guess_consumes_max_count).sum.to_i
    @total_consumes_count = @total_consumes.count
    @used_consumes_count = @total_consumes.used.count

    @consumes = @consumes.page(params[:page])

    respond_to do |format|
      format.html
      format.xls
    end
  end


  def find_consume
    @shop_branches = current_user.shop_branches.used
    @consume = Consume.find_by_id(params[:id])
    render layout: 'application_pop'
  end

  def use_consume
    @consume = current_user.wx_mp_user.consumes.unused.unexpired.find(params[:id])
    shop_branch = ShopBranch.find_by_id(params[:shop_branch_id])
    @consume.use!(shop_branch)
    flash.notice = '操作成功'
    render js: "parent.location.reload();"
  end

  def new
    @activity = current_user.wx_mp_user.new_activity_for_guess
  end

  def create
    @activity = current_user.wx_mp_user.new_activity_for_guess
    @activity.attributes = params[:activity]
    if @activity.save
      redirect_to settings_guess_path(@activity), notice: '保存成功'
    else
      render_with_alert "new", "保存失败，#{@activity.errors.full_messages.first}"
    end
  end

  def load_more
    if params[:last_id].present?
      last_id = params[:last_id].to_i
      @questions = current_user.guess_questions.where("status = ? and id < ?", Activity::SETTED, last_id).limit(9).order('created_at desc')
      @has_more =  current_user.guess_questions.where("status = ? and id < ?", Activity::SETTED, @questions.last.try(:id)).exists?
    end
  end

  def update
    @activity.attributes = params[:activity]
    if @activity.save
      if params[:activity_question_ids].present?
        params[:activity_question_ids].to_a.each do |question_id|
          @activity.guess_activity_questions.where(question_id: question_id).first_or_create
        end
      end
      if params[:return_url].present?
        redirect_to params[:return_url]
      else
        redirect_to guesses_activities_path, notice: "保存成功"
      end
    else
      render_with_alert :edit, "保存失败，#{@activity.errors.full_messages.first}"
    end
  end

  def destroy
    @activity.mark_delete!
    redirect_to :back, notice: "操作成功"
  end

  private
    def set_help_anchor
      @help_anchor = '#nav_180'
    end

    def find_activity
      @activity = current_user.wx_mp_user.activities.guess.show.find(params[:id])
    end

    def set_coupons_and_gifts
      coupon_activity = current_user.wx_mp_user.activities.coupon.show.first
      if coupon_activity.present?
        @coupons = coupon_activity.coupons.normal.can_apply.select {|coupon| coupon.appliable? }
      else
        @coupons  = []
      end
    end
end
