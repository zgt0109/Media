class Api::V1::BaseController < ActionController::Base

  skip_before_filter :verify_authenticity_token
  before_filter :set_access_control_headers, :authenticate_user

  private
    def set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = '*'
      headers['Access-Control-Allow-Headers'] = '*'
    end

    def request_params
      HashWithIndifferentAccess.new(JSON(request.raw_post)) rescue params
    end

    def authenticate_user
      role_id, token = request_params.values_at(*%w[role_id token])
      klass = request_params[:role] == 'supplier' ? Supplier : SubAccount
      @login_user = klass.where(id: role_id).first
      return render_error('参数不正确，找不到商家或门店') if @login_user.blank?
      # return render_error('token不正确') if @login_user.auth_token != token
    end

    def current_supplier_id
      @login_user.is_a?(SubAccount) ? @login_user.user.supplier_id : @login_user.id
    end

    def current_shop_branch_id
      @login_user.user_id if request_params[:role] == 'micro_shop'
    end

    def current_shop_branch
      ShopBranch.find(current_shop_branch_id) if current_shop_branch_id.present?
    end

    def require_supplier
      render_error('只有商户才能执行该操作') if request_params[:role] != 'supplier'
    end

    def require_vip_user
      id, trade_token = request_params[:vip_user_id], request_params[:vip_trade_token]
      @vip_user = @login_user.vip_users.visible.where(id: id).first

      vip_checker = VipUserChecker.new(@vip_user, nil, trade_token)
      redirect_to render_error(vip_checker.error_message) if vip_checker.error?
    end

    def render_error(msg, prefix: '操作失败：')
      render json: {error: 1, error_msg: "#{prefix}#{msg}"} and return false
    end

    def render_success
      render json: { success: 1 }
    end

    def calc_recent_counts(records, start_date = Date.today - 7, end_date = Date.yesterday)
      info = records.inject(Hash.new(0)) { |h, record| h.merge! record.created_date => record.kount }

      (start_date..end_date).inject({}) do |h, date|
        h.merge! date.to_s[5..-1] => info[date]
      end
    end
end
