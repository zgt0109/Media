class Biz::PointGiftsController < Biz::VipController
  before_filter :find_gift, only: [:show, :update, :destroy, :edit, :gift_exchange, :use_gift, :update_consumes, :exchange_info]
  before_filter :find_shop_branches, only: [:new, :update, :create, :edit]

  def index
    @search = current_site.point_gifts.online.latest.where('status > 0').search(params[:search])
    @gifts = @search.page(params[:page])
  end

  def new
    @gift = current_site.point_gifts.new(award_in_days: 7)
    render :form, layout: 'application_pop'
  end

  def edit
    render :form, layout: 'application_pop'
  end

  def save
    params[:point_gift][:shop_branch_ids] = params[:point_gift][:shop_branch_ids].to_a.map(&:to_i)
    params[:point_gift][:vip_grade_ids]   = params[:point_gift][:vip_grade_ids].to_a.map(&:to_i)
    @gift ||= current_site.point_gifts.new
    @gift.attributes = params[:point_gift]
    if @gift.save
      flash[:notice] = "保存成功"
      render inline: "<script>parent.location.reload();</script>"
    else
      render_with_alert :form, "保存失败：#{@gift.errors.full_messages.join('，')}", layout: 'application_pop'
    end
  end
  alias create save
  alias update save

  def destroy
    @gift.update_attributes(status: PointGift::DELETED)
    redirect_to point_gifts_path, notice: "操作成功"
  end

  def get_shop
    @city_id = params[:city_id]
    @shop_branchs = current_site.shop_branches.used.where(province_id: params[:province_id], city_id: params[:city_id])
    render :partial => "shop_branch"
  end

  def gift_exchange
    @total_point_gift_exchanges = @gift.point_gift_exchanges.latest
    @search = @total_point_gift_exchanges.search(params[:search])
    @point_gift_exchanges = @search.page(params[:page])

    @shop_branches = @gift.shop_branch_limited ? current_site.shop_branches.used.where(id: @gift.shop_branch_ids) : current_site.shop_branches.used
    @status = params[:search][:status_eq] if params[:search]
    @shop_branch = params[:search][:consume_applicable_id_eq] if params[:search]

    respond_to do |format|
      format.html { render action: 'gift_exchange' }
      format.xls {
                send_data(PointGift.export_excel(@search.page(params[:page_exl]).per(1000)),
                :type => "text/excel;charset=utf-8; header=present",
                :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
              }
    end
  end

  def use_gift
    @shop_branches = @gift.shop_branch_limited ? current_site.shop_branches.used.where(id: @gift.shop_branch_ids) : current_site.shop_branches.used
    render layout: 'application_pop'
  end

  def exchange_info
    @consume = @gift.consumes.unused.unexpired.where(code: params[:code]).first
    @exchange = @consume.try(:consumable)
    if !@consume.try(:used?) && !@consume.try(:expired?) && @exchange
      render json: {find_status: 1, gift_code: params[:code], point_gift_name: @exchange.point_gift.try(:name),
                    created_at: @exchange.try(:created_at).to_s[0..15],
                    expired_at: (@consume.expired_at.to_s[0..15].presence || '长期有效')}
    else
      render json: {find_status: 0}
    end
  end

  def update_consumes
    @consume = @gift.consumes.unused.unexpired.where(code: params[:code]).first
    @shop_branch = current_site.shop_branches.used.any_shops(@gift.try(:shop_branch_ids)).where(id: params[:shop_branch_id]).first
    if @consume && @consume.use!( @shop_branch )
      flash[:notice] = "使用成功"
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, alert: "SN码不正确", layout: 'application_pop'
    end
  end

  private

  def find_gift
    @gift = current_site.point_gifts.find params[:id]
  end

  def find_shop_branches
    if @gift.try(:shop_branch_ids).present?
      @shop_branchs = []
      city_ids = current_site.shop_branches.used.where(id: @gift.try(:shop_branch_ids)).uniq.pluck(:city_id)
      city_ids.each_with_index do |city_id,index|
        branch = current_site.shop_branches.used.where(city_id: city_id)
        @shop_branchs << branch
        if index == 0
          @province_id = branch.first.province_id
          @city_id = branch.first.city_id
        end
      end
    else
      @province_id = 9
      @city_id = 73
      @shop_branchs = [current_site.shop_branches.used.where(province_id: 9, city_id: 73)]
    end
  end
end
