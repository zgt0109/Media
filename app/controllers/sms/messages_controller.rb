# -*- encoding : utf-8 -*-
class Sms::MessagesController < ApplicationController
  skip_before_filter *ADMIN_FILTERS, only: [:send_message, :send_text_message]

  def switch
    @partialLeftNav = "/layouts/partialLeftSys"
  end

  def toggle
    result = current_site.is_open_sms? ? current_site.close_sms : current_site.open_sms
    respond_to do |format|
      if result
        format.js { render js: "$('.info').html('');$('.btn-pluin').attr('href', '#{toggle_sms_messages_path}');showTip('success', '操作成功');" }
      else
        format.js { render js: "showTip('warning', '操作失败');" }
      end
    end
  end

  # 参数 operation_id in (1:会员卡,2:电商,3:餐饮,4:酒店,5:小区,6:活动,7:微服务,8:其它)
  # 发送付费短信http接口,调用方法如下：
  # RestClient.post("http://dev.winwemedia.local:3000/sms/messages/send_message", {phone: '13262902619', sms_params: { code: 123 }, operation_id: '2', site_id: 10001, userable_id: 10001, userable_type: 'User'})
  # 发送免费短信http接口调用方法如下：
  # RestClient.post("http://dev.winwemedia.local:3000/sms/messages/send_message", {phone: '13262902619', sms_params: { code: 123 }, operation_id: '2', site_id: 10001, userable_id: 10001, userable_type: 'User', is_free: 1})
  def send_message
    errors = []
    errors << "参数必须带有 wx_mp_user_open_id 或 site_id" if params[:wx_mp_user_open_id].blank? && params[:site_id].blank?
    errors << "参数必须带有 phone, sms_params 和 operation_id" if params[:phone].blank? || params[:sms_params].blank? || params[:operation_id].blank?
    errors << "短信通知功能未包含【#{params[:operation_id]}】模块" unless SmsExpense.operations.include?(params[:operation_id].to_i)

    if errors.blank?
      if params[:site_id].present?
        site = Site.where(id: params[:site_id]).first
      elsif params[:wx_mp_user_open_id].present?
        wx_mp_user = WxMpUser.where(openid: params[:wx_mp_user_open_id]).first
        site = wx_mp_user.site
      end

      errors << "商户不存在" unless site

      sms_options = { mobiles: params[:phone], template_code: params[:template_code], params: params[:sms_params] }
      options = { is_free: false, operation_id: params[:operation_id], site_id: params[:site_id], userable_id: params[:userable_id], userable_type: params[:userable_type] }

      result = site.send_message(sms_options, options)

      # result = site.send_message(params[:phone], params[:content], !!params[:is_free], params) if site

      errors = errors + result[:errors] if result.present? && result[:errors].present?
    end

    render text: errors.present? ? errors.join("\n") : '商户短信通知发送成功'
  end

  # 发送免费短信http接口,调用方法如下：
  # RestClient.post("http://dev.winwemedia.local:3000/sms/messages/send_text_message", {phone: '13262902619', code: '123456', userable_id: 10000, userable_type: 'User', source: 'ec', token: 'qwertyuiop[]asdfghjklzxcvbnm'})
  def send_text_message
    errors = []
    %w(phone content userable_id userable_type source token).each do |key|
    	errors << "#{key.to_s}不能为空" if params[key].blank?
    end

    errors << "token不存在" unless params[:token] == 'qwertyuiop[]asdfghjklzxcvbnm'

    if errors.blank?
      sms_service = SmsAlidayu.new
      phones = params[:phone].split(',').map(&:to_s).map{|m| m.gsub(' ', '')}.compact.uniq
      # TODO just for get code
      sms_service.send_code_for_verify(phones, params[:code], {userable_id: params[:userable_id], userable_type: params[:userable_type], source: params[:source]})
      # 短信发送失败，添加错误信息
      errors << sms_service.error_message if sms_service.error?
    end

    if errors.blank?
      render json: {result: 'success'}
    else
      render json: {result: 'failure', error_msg: errors.join(',')}
    end
  end

end
