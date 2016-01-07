class Huodong::WxCardsController < ApplicationController
	before_filter :require_wx_mp_user
	before_filter :find_activity, only: [:card_admins,:card_consumes,:card_reports]

	def index
		@activity = current_user.activities.where(activity_type_id: Activity::WX_CARD, wx_mp_user_id:current_user.wx_mp_user.id, status:1, activityable_type: nil).first_or_initialize
	end

	def card_admins
		@total_wx_cards = current_user.cards.show.latest
		@search = @total_wx_cards.search(params[:search])
		@wx_cards = @search.page(params[:page])
	end

	def card_consumes
		@total_consumes = current_user.wx_mp_user.consumes.wx_card.used.recent
    @search = @total_consumes.search(params[:search])
    @consumes = @search.page(params[:page])
    @total_count = @search.count

    respond_to :html, :xls
	end

	def card_reports
		@wx_card = current_user.cards.where(id: params[:search][:consumable_id_eq]).first if params[:search]
		@wx_card ||= current_user.cards.latest.first
		if @wx_card
			@search = @wx_card.consumes.order("id desc").search(params[:search])
			@total_consumes = @search.select('count(*) as kount, date(created_at) as created_date').group('created_date').map { |c| [c.created_date, c.kount] }.to_h
			@used_consumes  = @search.select('count(*) as kount, date(used_at) as used_date').group('used_date').map { |c| [c.used_date, c.kount] }.to_h
		else
			@search = Consume.none.search
			@total_consumes = @used_consumes = {}
	  end
	end

	def new
		@wx_card = current_user.cards.new(color: Wx::Card::COLORS.first)
		render :form
	end

	def show
		@wx_card = current_user.cards.find params[:id]
		render :form
	end

	def create
		@wx_card = current_user.cards.new(params[:wx_card])
		if @wx_card.save
			redirect_to card_admins_wx_cards_path, notice: "保存成功"
		else
			render_with_alert :form, "保存失败，#{@wx_card.errors.full_messages.first}"
		end
	end

	def destroy
		@wx_card = current_user.cards.find params[:id]
	  flash[:notice] = @wx_card.card_delete ? "删除成功" : "删除失败"
    render js: "location.reload();"
	end

	def use_consume
    render layout: 'application_pop'
  end

  def confirm_use_consume
    consume = current_user.wx_mp_user.consumes.wx_card.unused.unexpired.where(code: params[:sn_code]).readonly(false).first
    if consume.try(:can_use?) && consume.try(:wx_card?)
      consume.update_attributes(status: Consume::USED, used_at: Time.now) if consume.consumable.card_code_consume(consume.code)
      flash[:notice] = "核销成功"
      render inline: "<script>window.parent.location.reload();</script>"
    else
      render_with_alert :use_consume, '核销失败', layout: 'application_pop'
    end
  end

  def find_consume
    consume = current_user.wx_mp_user.consumes.wx_card.unused.unexpired.where(code: params[:sn_code]).readonly(false).first
    Rails.logger.warn consume.inspect
    if consume.try(:can_use?)
      render json: {consume_status: 1, baseinfo: consume.baseinfo, sn_code: params[:sn_code]}
    else
      render json: {consume_status: 0}
    end
  end

	private
    def find_activity
    	@activity = current_user.activities.where(activity_type_id: Activity::WX_CARD, wx_mp_user_id:current_user.wx_mp_user.id, status:1, activityable_type: nil).first
    	redirect_to wx_cards_path, alert: "请先进行基础设置！" unless @activity
    end
end