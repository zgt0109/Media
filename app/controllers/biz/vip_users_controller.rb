class Biz::VipUsersController < Biz::VipController
  before_filter :fetch_activity_and_vip_card
  before_filter :find_vip_user, except: [:index, :pending, :rejected, :deleted, :freezed, :inactive]

  def index
    @total_vip_users  = current_site.vip_users.sorted.normal.includes(:vip_grade, :supplier)
    @search           = @total_vip_users.search(params[:search])
    @vip_grade_select = params[:search][:vip_grade_id_eq] if params[:search]
    @vip_users        = @search.page(params[:page]).per(20)
    @total_count      = @search.count
    respond_to :html, :xls
  end

  def edit
    @view_only     = params[:view].present?
    @custom_fields = @vip_card.custom_fields.normal
    render layout: 'application_pop'
  end

  def info
    @custom_fields = @vip_card.custom_fields.normal
    render layout: 'application_pop'
  end

  def show
    @type = params[:type].present? ? params[:type] : 'show_user'
    transaction_options = {
      header_columns: %w(时间 金额 说明),
      only: [:created, :transaction_amount, :intro]
    }
    if @type == 'show_user'
      @custom_fields = @vip_card.custom_fields.normal
    elsif @type == 'money'
      @search = @vip_user.vip_user_transactions.search(params[:search])
      @transactions = @search.page(params[:page]).order('id DESC')
      respond_to do |format|
        format.html
        format.xls { send_data(@search.all.to_xls(transaction_options)) }
      end
    elsif @type == 'transactions'
      @total_point_transactions = @vip_user.point_transactions
      @search = @total_point_transactions.search(params[:search])
      @transactions = @search.page(params[:page]).order('id DESC')
      respond_to do |format|
        format.html
        format.xls { send_data(@search.all.to_xls(transaction_options)) }
      end
    elsif @type == 'given'
      @total_vip_givens = @vip_user.vip_givens.point
      @search = @total_vip_givens.includes(:vip_care).search(params[:search])
      @givens = @search.page(params[:page]).order('id DESC')
    elsif @type == 'grade'
      @total_vip_grade_logs = @vip_user.vip_grade_logs
      @search = @total_vip_grade_logs.search(params[:search])
      @vip_grade_logs = @search.page(params[:page]).order('id DESC')
    end

  end

  def pending
    @total_vip_users ||= current_site.vip_users.pending.sorted
    @search          = @total_vip_users.search(params[:search])
    @vip_users       = @search.page(params[:page])

    respond_to do |format|
      format.html { render :pending }
      format.xls
    end
  end

  def deleted
    @total_vip_users = current_site.vip_users.deleted.sorted
    pending
  end

  def rejected
    @total_vip_users = current_site.vip_users.rejected.sorted
    pending
  end

  def freezed
    @total_vip_users = current_site.vip_users.freeze_user.sorted
    pending
  end

  def inactive
    @total_vip_users = current_site.vip_users.inactive.sorted
    pending
  end

  def deny
    @vip_user.reject!
    redirect_to :back, notice:'成功拒绝'
  end

  def delete
    @vip_user.update_attributes(
      status: VipUser::DELETED,
      wx_user_id: -@vip_user.wx_user_id,
      vip_group_id: (@vip_user.vip_group_id && -@vip_user.vip_group_id),
      vip_grade_id: (@vip_user.vip_grade_id && -@vip_user.vip_grade_id)
    )
    redirect_to :back, notice:'成功删除'
  end

  def pass
    @vip_user.normal!
    redirect_to :back, notice:'成功通过'
  end

  def update
    if @vip_user.update_attributes(params[:vip_user])
      params[:custom_field].to_h.each do |field_id, value|
        custom_value = @vip_user.custom_values.where(custom_field_id: field_id).first_or_create(value: value)
        custom_value.update_attributes(value: value) if custom_value.value != value
      end
      flash[:notice] = '保存成功'
      render inline: '<script>parent.location.reload();</script>'
    else
      render_with_alert :edit, "保存失败，#{@vip_user.errors.full_messages.join('，')}"
    end
  end

  def freeze
    @vip_user.freeze!
    redirect_to :back, notice:'成功冻结'
  end

  def normal
    @vip_user.normal!
    redirect_to :back, notice:'成功解冻'
  end

  def award
    point = params[:point].to_i
    if point > 0
      @vip_user.point_transactions.create direction_type: PointTransaction::IN, points: point, site_id: current_site.id, point_type_id: -1, description: params[:description]
      @vip_user.update_attributes(total_points: @vip_user.total_points + point, usable_points: @vip_user.usable_points + point)
      render js: "$('#pop-award').fadeOut(); showTip('success', '操作成功');
      $('#usable_points_#{@vip_user.id}').html(#{@vip_user.usable_points});"
    else
      render js: "showTip('success', '操作失败');"
    end
  end

  def transactions
    @total_point_transactions = @vip_user.point_transactions
    @search = @total_point_transactions.search(params[:search])
    @transactions = @search.page(params[:page]).order('id DESC')
    render layout: 'application_pop'
  end

  def set_point
    render layout: 'application_pop'
  end

  def save_point
    points = params[:points].to_i
    return redirect_to :back, alert: '积分必须大于0' if points <= 0

    if params[:direction_type] == '1'
      if @vip_user.increase_points!(points)
        @vip_user.point_transactions.create direction_type: PointTransaction::ADJUST_IN, points: points, site_id: current_site.id, description: params[:description]
        flash[:notice] = '增加成功'
      else
        return redirect_to :back, alert: '增加失败,积分最小值为0'
      end
    elsif params[:direction_type].to_i == PointTransaction::ACTIVITY_PRIZE
      if @vip_user.increase_points!(points)
        @vip_user.point_transactions.create direction_type: PointTransaction::ACTIVITY_PRIZE, points: points, site_id: current_site.id, description: params[:description]
        flash[:notice] = '线上活动积分增加成功'
      else
        return redirect_to :back, alert: '线上活动积分增加失败,积分最小值为0'
      end
    else
      if @vip_user.decrease_points!(points)
        @vip_user.point_transactions.create direction_type: PointTransaction::OUT, points: points, site_id: current_site.id, description: params[:description]
        flash[:notice] = '减少成功'
      else
        return redirect_to :back, alert: '减少失败，积分最小值为0'
      end
    end

    if params[:source] == 'branch'
      redirect_to shops_vip_deals_path(session[:shop_supplier_id]), notice: '操作成功'
    else
      render inline: '<script>parent.document.location = parent.document.location;</script>';
    end
  end

  def money
    @total_vip_user_transactions = @vip_user.vip_user_transactions
    @search = @total_vip_user_transactions.search(params[:search])
    @vip_user_transactions = @search.page(params[:page]).order('id DESC')
    render layout: "application_pop"
  end

  def set_money
    @privileges = @vip_user.usable_privileges
    render layout: "application_pop"
  end

  def transaction_check
    amount = params[:amount].to_f
    direction_type = params[:direction_type]
    if %w(1 3).include?(direction_type)
      recharge_point_privilege = @vip_user.recharge_point_privilege(amount)
      recharge_discount_privilege = @vip_user.recharge_discount_privilege(amount)
      recharge_money_privilege = @vip_user.recharge_money_privilege(amount)
      @selected_privilege_ids = [recharge_discount_privilege.try(:id), recharge_point_privilege.try(:id), recharge_money_privilege.try(:id)].compact
      @pay_amount = @vip_user.recharge_discounted_amount(amount).to_f.round(2)

      @given_points = current_site.giving_points(amount, PointType::RECHARGE, {}, @vip_user, pay: false)
      @given_moneys = @vip_user.give_money(amount)
      @form = "charge"
    elsif ['2', '4'].include?(direction_type)
      consume_point_privilege = @vip_user.consume_point_privilege(amount)
      consume_discount_privilege = @vip_user.consume_discount_privilege(amount)
      @selected_privilege_ids = [consume_discount_privilege.try(:id), consume_point_privilege.try(:id)].compact
      @pay_amount = @vip_user.consumed_amount(amount).to_f.round(2)

      @given_points = current_site.giving_points(amount, PointType::CONSUME, {}, @vip_user, pay: false)
      @form = "consume"
    end
  end

  def save_money
    amount, direction = params[:amount].to_f, params[:direction].to_i
    return redirect_to :back, alert: '金额必须大于0' if amount <= 0

    direction_type         = { 1 => '增加', 2 => '减少', 3 => '充值', 4 => '消费' }[ direction ]
    error_message          = direction == 4 ? '可用余额不足，请充值后消费' : '操作失败，金额最小值为0'
    params[:amount_source] = { 3 => VipUserTransaction::SHOP_PAY_UP, 4 => VipUserTransaction::SHOP_PAY_DOWN }[ direction ]

    @vip_user.increase_amount!(amount,direction_type,params) if [1, 3].include?(direction)
    @vip_user.decrease_amount!(amount,direction_type,params) if [2, 4].include?(direction)

    return redirect_to :back, alert: error_message if @vip_user.errors.any?
    flash[:notice] = "#{direction_type}成功"

    if params[:source] == 'branch'
      redirect_to shops_vip_deals_path(session[:shop_supplier_id]), notice: '操作成功'
    else
      render inline: '<script>parent.location.reload();</script>';
    end
  end

  def set_grade
    render layout: 'application_pop'
  end

  def save_grade
    if params[:vip_grade_id].to_i == @vip_user.vip_grade_id
      flash[:notice] = '未进行等级调节操作'
    else
      vip_grade_log = @vip_user.vip_grade_logs.create site_id: current_site.id, old_vip_grade_id: @vip_user.vip_grade_id, old_vip_grade_name: @vip_user.vip_grade_name, description: params[:description]
      if @vip_user.update_attributes(vip_grade_id: params[:vip_grade_id], vip_grade_adjusted: true)
        vip_grade_log.update_attributes(now_vip_grade_id: @vip_user.vip_grade_id, now_vip_grade_name: @vip_user.vip_grade_name)
        flash[:notice] = '操作成功'
      else
        flash[:notice] = '操作失败'
      end
    end
    render inline: '<script>parent.location.reload();</script>'
  end

  def destroy
    @vip_user.destroy
    redirect_to :back, notice: '操作成功'
  end

  private
    def find_vip_user
      @vip_user = current_site.vip_users.find(params[:id])
    end

end
