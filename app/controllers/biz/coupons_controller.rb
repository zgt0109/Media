class Biz::CouponsController < ApplicationController
  before_filter :set_activity
  before_filter :set_coupons, except: [:consumes, :reports, :offline_consumes]
  before_filter :find_coupon, only: [:edit, :show, :update, :start, :stop,
                                     :move_up, :move_down, :new, :create, :destroy]
  before_filter :find_shop_branches, only: [:new, :update, :create, :edit, :show]
  def index
  end

  def create
    @coupon.attributes = params[:coupon]
    if @coupon.save
      @coupon.create_offline_consumes
      redirect_to coupons_path, notice: '保存成功'
    else
      render_with_alert :new, "保存失败: #{@coupon.errors.full_messages.join('\n')}"
    end
  end

  def update
    @coupon.attributes = params[:coupon]
    if @coupon.save
      @coupon.reset_offline_consumes
      redirect_to coupons_path, notice: '保存成功'
    else
      render_with_alert :new, "保存失败: #{@coupon.errors.full_messages.join('\n')}"
    end
  end

  def edit_activity
  end

  def destroy
    @coupon.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: '删除成功' }
      format.json { head :no_content }
    end
  end

  def reports
    search, used_search = filter_search
    @consumes = @activity.coupon_consumes.search(search).select("count(*) created_count, DATE(consumes.created_at) created_date").group('created_date').to_a

    @search = @activity.coupon_consumes.used.search(used_search)
    @used_consumes = @search.select('count(*) used_count, DATE(used_at) used_date, sum(coupons.value) coupons_value').group('used_date').to_a

    @sns         = @activity.coupons.sum(&:limit_count)
    @created_sns = @consumes.sum(&:created_count)
    @used_sns    = @used_consumes.sum(&:used_count)
    dates = [@consumes.first.try(:created_date), @consumes.last.try(:created_date), @used_consumes.first.try(:used_date), @used_consumes.last.try(:used_date)].compact
    min_date, max_date = dates.min, dates.max

    return @pag_consumes = Kaminari.paginate_array([]).page(params[:page]).per(20) if min_date.nil? || max_date.nil?

    @consumes_all = []
    (min_date..max_date).each do |day|
      @consumes_all << {
        day:             day.to_s,
        consume_created: @consumes.find{ |c| c.created_date == day}.try(:created_count),
        consume_used:    @used_consumes.find{ |c| c.used_date == day}.try(:used_count),
        discount:        @used_consumes.find{ |c| c.used_date == day}.try(:coupons_value)
      }
    end

    @pag_consumes = Kaminari.paginate_array(@consumes_all).page(params[:page]).per(20)

    respond_to :html, :xls
  end

  def start
    @coupon.online!
    redirect_to coupons_path, notice: '操作成功'
  end

  def stop
    @coupon.offline!
    redirect_to coupons_path, notice: '操作成功'
  end

  def move_up
    @coupon.move_higher
    redirect_to coupons_path, notice: '操作成功'
  end

  def move_down
    @coupon.move_lower
    redirect_to coupons_path, notice: '操作成功'
  end

  def use_consume
    render layout: 'application_pop'
  end

  def confirm_use_consume
    consume = current_site.consumes.unused.unexpired.coupon_use_start.where(code: params[:sn_code]).readonly(false).first
    if consume.try(:can_use?)
      consume.update_attributes(status: Consume::USED, applicable_type: 'ShopBranch', applicable_id: params[:shop_branch_id], used_at: Time.now)
      flash[:notice] = "核销成功"
      render inline: "<script>window.parent.location.reload();</script>"
    else
      render_with_alert :use_consume, '核销失败', layout: 'application_pop'
    end
  end

  def find_consume
    consume = current_site.consumes.unused.unexpired.coupon_use_start.where(code: params[:sn_code]).readonly(false).first
    Rails.logger.warn consume.inspect
    if consume.try(:can_use?)
      render json: {consume_status: 1, baseinfo: consume.baseinfo, sn_code: params[:sn_code]}
    else
      render json: {consume_status: 0}
    end
  end

  def consumes
    @search = Consume.used.select("coupons.name AS consume_coupon_name, consumes.status, coupons.value_by AS consume_value_by, coupons.value AS consume_value, consumes.code, consumes.mobile, consumes.created_at AS consume_created_at, consumes.used_at, consumes.consumable_type, consumes.consumable_id, shop_branches.name AS shop_name").joins("INNER JOIN coupons ON consumes.consumable_id = coupons.id AND consumes.consumable_type = 'Coupon' LEFT JOIN shop_branches ON  consumes.applicable_id = shop_branches.id AND consumes.applicable_type = 'ShopBranch'").where("coupons.activity_id = ?", @activity.id).search(params[:search])
    @consumes_all = @search.order('consumes.id DESC')
    @consumes     = @consumes_all.page(params[:page])
    respond_to :html, :xls
  end

  def offline_consumes
    @search = Consume.select("coupons.name AS consume_coupon_name, consumes.status, coupons.value_by AS consume_value_by, coupons.value AS consume_value, consumes.code, consumes.mobile, consumes.created_at AS consume_created_at, consumes.used_at, consumes.consumable_type, consumes.consumable_id, shop_branches.name AS shop_name").joins("INNER JOIN coupons ON consumes.consumable_id = coupons.id AND consumes.consumable_type = 'Coupon' LEFT JOIN shop_branches ON  consumes.applicable_id = shop_branches.id AND consumes.applicable_type = 'ShopBranch'").where("coupons.activity_id = ?", @activity.id).search(params[:search])
    @consumes_all = @search.order('consumes.id DESC')
    @consumes     = @consumes_all.page(params[:page])
    respond_to :html, :xls
  end

  private
    def set_coupons
      return render_404 unless @activity
      @search  = @activity.coupons.normal.search(params[:search])
      @coupons = @search.order(:position).page(params[:page])
    end

    def find_coupon
      @coupon = @activity.coupons.find_by_id(params[:id]) || @activity.coupons.new
    end

    def set_activity
      if current_site.activities.coupon.exists?
        @activity = current_site.activities.coupon.show.first
      else
        @activity = current_site.create_activity_for_coupon
      end
    end

    def activity_time_valid?
      now = Time.now.to_s
      start_at, end_at = params[:coupon].values_at(:apply_start, :apply_end)
      if start_at && end_at
        return now <= start_at && start_at < end_at
      end
      return false
    end

    def activity_time_invalid?
      !activity_time_valid?
    end

    def filter_search
      search = params[:search].to_h
      search['created_at_gte'] += ' 00:00:00' if search['created_at_gte'].present?
      search['created_at_lte'] += ' 23:59:59' if search['created_at_lte'].present?

      used_search = { used_at_gte: search['created_at_gte'], used_at_lte: search['created_at_lte'] }.merge(search).reject { |k| k =~ /created/ }

      if search['applicable_id_eq'].blank?
        search.delete('applicable_id_eq')
        search.delete('applicable_type_eq')
        used_search.delete('applicable_id_eq')
        used_search.delete('applicable_type_eq')
      end

      # search = search.dup.merge('applicable_id_eq' => '', 'applicable_type_eq' => '')
      [search, used_search]
    end

    def find_shop_branches
      if @coupon.try(:shop_branch_ids).present?
        @shop_branchs = []
        city_ids = current_site.shop_branches.used.where(id: @coupon.try(:shop_branch_ids)).uniq.pluck(:city_id)
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

