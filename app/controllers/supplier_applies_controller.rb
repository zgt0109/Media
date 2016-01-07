# -*- coding: utf-8 -*-
class SupplierAppliesController < ApplicationController
  skip_before_filter *ADMIN_FILTERS

  def create
    if params[:supplier_apply][:fxt]
      attrs = params[:supplier_apply]
      attrs.merge!(
        admin_user_id: 23,
        product_agent_type: SupplierApply::VCL_FXT,
        apply_type: SupplierApply::APPLY_FROM_winwemedia,
        business_type: SupplierApply::AGENT_BUSINESS,
        intro: "暂无",
        status: SupplierApply::ACTIVE
      )
      attrs.delete(:fxt)
    end

    @supplier_apply = SupplierApply.new(params[:supplier_apply])

    if @supplier_apply.save
      render json: {code: 0, message: "申请提交成功!"}
    else
      render json: {code: -1, message: @supplier_apply.full_error_message }
    end
  rescue => error
    render json: {code: -1, message: "提交失败#{error}", num: 2, status: 0}
  end

  def send_sms
    return render json: { errcode: -1 } if session[:image_code].blank? || params[:verify_code].blank? || session[:image_code] != params[:verify_code]

    session[:captcha], session[:mobile] = rand(100000..999999).to_s, params[:mobile].to_s
    SmsService.new.singleSend(session[:mobile], "验证码：#{session[:captcha]}")
    # session[:image_code] = nil
    render json: { errcode: 0 }
  end

end
