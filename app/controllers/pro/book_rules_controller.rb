class Pro::BookRulesController < Pro::ShopBaseController
  # before_filter :set_booking_order, only: [:show, :edit, :update, :destroy, :cancele, :complete]

  def index
    if current_site.shop_branches.used.count == 0
      return redirect_to :back, alert: '请先添加门店'
    end 
    if params[:rule_type]
      shop_branch_id = params[:shop_branch_id] ||= (current_shop_branch || current_site.shop_branches.used.first)
      @shop_branch = current_site.shop_branches.used.find(shop_branch_id)

      @book_rule = case params[:rule_type]
        when '1' then @shop_branch.book_dinner_rule
        when '2' then @shop_branch.book_table_rule
        when '3' then @shop_branch.take_out_rule
      end

    else
      @book_rule = BookRule.new(rule_type: params[:rule_type])
    end

    @book_rule.book_time_ranges.new
  end

  def create
    @book_rule = BookRule.new(params[:book_rule])
    @book_rule.book_time_ranges.new
    if @book_rule.save!
      redirect_to :back, notice: "保存成功"
    else
      redirect_to :back, notice: "保存失败"
    end

  end

  def update
    @book_rule = BookRule.find(params[:id])
    if @book_rule.update_attributes!(params[:book_rule])
      return redirect_to :back, notice: "更新成功"
    else
      return redirect_to :back, notice: "更新失败"
    end
  end

  def assign
    @book_rule = BookRule.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def copy
    @book_rule = BookRule.find(params[:id])
    shop_branches = ShopBranch.where(id: params[:branch_ids])
    @book_rule.copy_settings_to_branches shop_branches
    respond_to do |format|
      format.js
    end
  end

  def show
    render layout: 'application_pop'
  end

  def destroy
    @booking_order.destroy

    respond_to do |format|
      format.html { redirect_to booking_orders_url }
      format.json { head :no_content }
    end
  end
  
  def complete
    @booking_order.complete!
    redirect_to booking_orders_url, notice: '已完成'
  end
  
  def cancele
    @booking_order.cancele!
    redirect_to booking_orders_url, notice: '已取消'
  end

  private

  def authorize_shop_branch_account
    return if current_user.is_a?(Account)

    # if current_user.is_gift?
    #   if current_user.disabled? || !current_user.can_any?('manage_catering_book_rules', 'manage_takeout_book_rules')
    #     render_404 and return false
    #   end
    # else
      authorize_shop_branch_account! 'manage_catering_book_rules' if current_site.industry_food?
      authorize_shop_branch_account! 'manage_takeout_book_rules' if current_site.industry_takeout?
    # end
  end

end
