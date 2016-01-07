class Huodong::WxShakesController < ApplicationController
	before_filter :require_wx_mp_user
	before_filter :find_wx_shake, except: [ :index, :new, :create, :shake_round, :shake_round_show ]
	
	def index
		@total_wx_shakes = current_user.wx_shakes.show.order('created_at DESC')
		@search = @total_wx_shakes.search(params[:search])
    @wx_shakes = @search.page(params[:page])
	end

	def shake_round
		@total_wx_shake_rounds = current_user.wx_shake_rounds.order('id DESC')
		@search = @total_wx_shake_rounds.search(params[:search])
    @wx_shake_rounds = @search.page(params[:page])

    respond_to do |format|
      format.html
      format.xls {
                send_data(WxShakeRound.export_excel(@search),
                :type => "text/excel;charset=utf-8; header=present", 
                :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
              }
    end
	end

	def shake_round_show
		@wx_shake_round = current_user.wx_shake_rounds.where(id: params[:id]).first
    # @total_wx_shake_users = current_user.wx_shake_users.wx_shake_at.where(wx_shake_id: @wx_shake_round.wx_shake_id)
    @total_wx_shake_users = current_user.wx_shake_users.wx_shake_at.joins("left join wx_shake_prizes on wx_shake_users.wx_user_id = wx_shake_prizes.wx_user_id and wx_shake_users.wx_shake_id = wx_shake_prizes.wx_shake_id and wx_shake_prizes.wx_shake_round_id= #{@wx_shake_round.id}").where(wx_shake_id: @wx_shake_round.wx_shake_id).order('IFNULL(wx_shake_prizes.user_rank, 1000000) asc')

		@search = @total_wx_shake_users.search(params[:search])
    @wx_shake_users = @search.page(params[:page])
    # max_rank = @wx_shake_round.wx_shake_prizes.maximum(:user_rank).to_i
    # arr = @search.relation.sort_by do |x|
    #   rank = x.get_user_rank(@wx_shake_round.id)
    #   rank.to_i == 0 ? (rank.to_i+max_rank+1) : rank.to_i
    # end
    # @wx_shake_users = Kaminari.paginate_array(arr).page(params[:page])

    respond_to do |format|
      format.html {render layout: "application_pop"}
      format.xls {
                send_data(WxShakePrize.export_excel(@search.page(params[:page_exl]).per(2000), @wx_shake_round.id),
                :type => "text/excel;charset=utf-8; header=present", 
                :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
              }
    end
	end

	def new
		@wx_shake = current_user.wx_shakes.new(activity: Activity.new(activity_type_id: 55))
    render :form
	end

	def edit
    render :form
	end

	def create
    @wx_shake = current_user.wx_shakes.new(params[:wx_shake])
		return render_with_alert :form, "保存失败，请先设置公众号二维码！" unless current_user.wx_mp_user.qrcode_url.present?
    if @wx_shake.save
      redirect_to wx_shakes_path, notice: "保存成功"
    else
    	render_with_alert :form, "保存失败，#{@wx_shake.errors.full_messages.first}"
    end
	end

	def update
		if @wx_shake.update_attributes(params[:wx_shake])
			redirect_to wx_shakes_path, notice: "保存成功"
		else
			render_with_alert :form, "保存失败，#{@wx_shake.errors.full_messages.first}"
		end
	end

	def set_status
		status = @wx_shake.stopped? ? WxShake::NORMAL : WxShake::STOPPED
    @wx_shake.update_column(:status, status)
    @wx_shake.activity.update_column(:status, status)
    redirect_to :back, notice: "操作成功"
  end

  def set_prize_status
  	wx_shake_prize = @wx_shake.wx_shake_prizes.where(id: params[:prize_id]).first
    wx_shake_prize.update_column(:status, WxShakePrize::USED)
    render js: "$('#prize_#{params[:prize_id]}').html('已领奖');$('#status_#{params[:prize_id]}').html('');"
  end

  private
    def find_wx_shake
      @wx_shake = current_user.wx_shakes.where(id: params[:id]).first
    end
	
end