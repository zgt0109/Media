class Huodong::ShakesController < ApplicationController
	before_filter :find_shake, except: [ :index, :new, :create, :shake_round, :shake_round_show ]
	
	def index
		@total_shakes = current_site.shakes.show.order('created_at DESC')
		@search = @total_shakes.search(params[:search])
    @shakes = @search.page(params[:page])
	end

	def shake_round
		@total_shake_rounds = current_site.shake_rounds.order('id DESC')
		@search = @total_shake_rounds.search(params[:search])
    @shake_rounds = @search.page(params[:page])

    respond_to do |format|
      format.html
      format.xls {
                send_data(ShakeRound.export_excel(@search),
                :type => "text/excel;charset=utf-8; header=present", 
                :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
              }
    end
	end

	def shake_round_show
		@shake_round = current_site.shake_rounds.where(id: params[:id]).first
    # @total_shake_users = current_site.shake_users.shake_at.where(shake_id: @shake_round.shake_id)
    @total_shake_users = current_site.shake_users.shake_at.joins("left join shake_prizes on shake_users.user_id = shake_prizes.user_id and shake_users.shake_id = shake_prizes.shake_id and shake_prizes.shake_round_id= #{@shake_round.id}").where(shake_id: @shake_round.shake_id).order('IFNULL(shake_prizes.user_rank, 1000000) asc')

		@search = @total_shake_users.search(params[:search])
    @shake_users = @search.page(params[:page])
    # max_rank = @shake_round.shake_prizes.maximum(:user_rank).to_i
    # arr = @search.relation.sort_by do |x|
    #   rank = x.get_user_rank(@shake_round.id)
    #   rank.to_i == 0 ? (rank.to_i+max_rank+1) : rank.to_i
    # end
    # @shake_users = Kaminari.paginate_array(arr).page(params[:page])

    respond_to do |format|
      format.html {render layout: "application_pop"}
      format.xls {
                send_data(ShakePrize.export_excel(@search.page(params[:page_exl]).per(2000), @shake_round.id),
                :type => "text/excel;charset=utf-8; header=present", 
                :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
              }
    end
	end

	def new
		@shake = current_site.shakes.new(activity: Activity.new(activity_type_id: 55))
    render :form
	end

	def edit
    render :form
	end

	def create
    @shake = current_site.shakes.new(params[:shake])
		return render_with_alert :form, "保存失败，请先设置公众号二维码！" unless current_site.wx_mp_user.qrcode_url.present?
    if @shake.save
      redirect_to shakes_path, notice: "保存成功"
    else
    	render_with_alert :form, "保存失败，#{@shake.errors.full_messages.first}"
    end
	end

	def update
		if @shake.update_attributes(params[:shake])
			redirect_to shakes_path, notice: "保存成功"
		else
			render_with_alert :form, "保存失败，#{@shake.errors.full_messages.first}"
		end
	end

	def set_status
		status = @shake.stopped? ? Shake::NORMAL : Shake::STOPPED
    @shake.update_column(:status, status)
    @shake.activity.update_column(:status, status)
    redirect_to :back, notice: "操作成功"
  end

  def set_prize_status
  	shake_prize = @shake.shake_prizes.where(id: params[:prize_id]).first
    shake_prize.update_column(:status, ShakePrize::USED)
    render js: "$('#prize_#{params[:prize_id]}').html('已领奖');$('#status_#{params[:prize_id]}').html('');"
  end

  private
    def find_shake
      @shake = current_site.shakes.where(id: params[:id]).first
    end
	
end