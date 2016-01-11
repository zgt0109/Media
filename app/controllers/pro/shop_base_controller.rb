# coding: utf-8
class Pro::ShopBaseController < ApplicationController
  before_filter :require_wx_mp_user, :require_industry
  skip_before_filter :filter_out_shop_branch_sub_account
  before_filter :authorize_shop_branch_account
  helper_method :can_see?

  private
    # def update_industry
    #   industry_id = params[:industry_id].to_i if params[:industry_id].present?
    #   if industry_id && current_user.has_industry_for?(industry_id)
    #     supplier = current_user.is_a?(Account) ? current_user : current_shop_account
    #     if supplier.supplier_industry_id != industry_id
    #       supplier.update_attributes(supplier_industry_id: industry_id)
    #       current_user(true) # force reload current_user to update supplier_industry_id
    #     end
    #   end
    # end

    def require_industry
      if current_site.has_industry_for?(10001) || current_site.has_industry_for?(10002) || current_site.has_industry_for?(10007)
        industry_id = params[:industry_id].to_i
        if [10001,10002,10007].include?(industry_id)
          session[:current_industry_id] = industry_id
        else
          session[:current_industry_id] = 10001 unless session[:current_industry_id]
        end 
      else
        redirect_to console_url, alert: '你没有权限使用此功能'
      end
    end

    def authorize_shop_branch_account
      render_404 && false if current_user.is_a?(SubAccount)
    end

    def authorize_shop_branch_account!(do_action)
      render_404 && false if current_user.is_a?(SubAccount) && (current_user.disabled? || current_user.can_not?(do_action))
    end

    def can_see?
      current_user.is_a?(Account)
    end
end
