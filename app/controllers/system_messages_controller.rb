class SystemMessagesController < ApplicationController
  skip_before_filter *ADMIN_FILTERS, only: [:api]
  before_filter :set_message, only: [:update, :show, :destroy, :read, :ajax_update]

  def index
    current_user.update_all_system_messages
    @search = current_user.system_messages.search(params[:search])
    @messages = @search.page(params[:page])
  end

  def ajax_update
    @message.read! unless @message.is_read
    return render text: 'succeed'
  rescue => e
    return render text: "#{e}"
  end

  def destroy
    if @message.destroy
      redirect_to :back, notice: '删除成功'
    else
      redirect_to :back, alert: '删除失败'
    end
  end

  def read
    @message.read! unless @message.is_read
    if @message.skip_url_attrs.present?
      redirect_to @message.skip_url_attrs[:url]
    else
      redirect_to :back, alert: '跳转失败: 提醒消息对应模块不存在'
    end
  end

  def read_all
    current_user.update_all_system_messages
    redirect_to system_messages_path
  end

  # 系统提醒信息http接口,调用方法如下：
  # RestClient.post("http://dev.winwemedia.local:3000/system_messages/api", {supplier_id: 10117, content: '电商短信测试', module_id: '1'})
  def api

    errors = []
    %i(supplier_id module_id content).each{|k| errors << "参数必须带有 #{k.to_s}" if params[k].blank? }
    errors << "提醒消息中不包含 #{params[:module_id]} 模块" unless smm = SystemMessageModule.where(module_id: params[:module_id]).first

    if errors.blank?
      @supplier = Supplier.where(id: params[:supplier_id]).first
      @supplier ? @supplier.send_system_message(params, smm) : errors << "商户不存在"
    end

    return render text: errors.present? ? errors.join("\n") : '提醒信息接收成功'
  end

  private

    def set_message
      @message = current_user.system_messages.where(id: params[:id]).first
      redirect_to :back, alert: '提醒消息不存在或已删除' unless @message
    end

end
