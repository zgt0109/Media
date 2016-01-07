class Biz::VipExternalHttpApisController < ApplicationController
  layout 'application_pop'
  before_filter :find_api, only: [ :edit, :update, :destroy ]
  before_filter do
    @partialLeftNav  = 'layouts/partialLeftAPI'
  end

  def index
    @vip_external_http_apis = current_user.vip_external_http_apis.page( params[:page] )
    render layout: 'application'
  end

  def new
    @vip_external_http_api = VipExternalHttpApi.new
    render :form
  end

  def create
    @vip_external_http_api = current_user.vip_external_http_apis.new( params[:vip_external_http_api].merge(vip_card_id: current_user.vip_card.id, wx_mp_user_id: current_user.wx_mp_user.id) )
    if @vip_external_http_api.save
      flash[:notice] = "保存成功"
      render inline: "<script>parent.location.reload();</script>"
    else
      render_with_alert :form, "保存失败，#{@vip_external_http_api.errors.full_messages.join("，")}"
    end
  end

  def edit
    render :form
  end

  def update
    if @vip_external_http_api.update_attributes( params[:vip_external_http_api] )
      flash[:notice] = "保存成功"
      render inline: "<script>parent.location.reload();</script>"
    else
      render_with_alert :form, "保存失败，#{@vip_external_http_api.errors.full_messages.join("，")}"
    end
  end

  def destroy
    @vip_external_http_api.destroy
    redirect_to vip_external_http_apis_path, notice: "删除成功"
  end

  private
    def find_api
      @vip_external_http_api = current_user.vip_external_http_apis.find params[:id]  
    end
end