class QrcodeChannelTypesController < ApplicationController
  before_filter :require_wx_mp_user#, :mp_user_is_sync

  def index
    @qrcode_channel_types = current_site.qrcode_channel_types.normal.latest.page(params[:page])
  end

  def index_json
    # data = current_site.qrcode_channel_types.normal.map do |type|
    #   [type.name, type.description, qrcode.id]
    # end
    data = [ ["分类1", "渠道的分类1", 1], 
              ["分类2", "渠道的分类2", 2] ]
    render json: { aaData: data }
  end

  def new
    @qrcode_channel_type = current_site.qrcode_channel_types.new
    render :form, layout: 'application_pop'
  end

  def edit
    @qrcode_channel_type = current_site.qrcode_channel_types.find(params[:id])
    render :form, layout: 'application_pop'
  end

  def create
    @qrcode_channel_type = current_site.qrcode_channel_types.new(params[:qrcode_channel_type])

    if @qrcode_channel_type.save
      flash[:notice] = "添加成功"
      render inline: "<script>window.parent.document.getElementById('weisiteModal').style.display='none';window.parent.location.reload();</script>"
    else
      flash[:alert] = "添加失败"
      render :form, layout: 'application_pop'
    end
  end

  def update
    @qrcode_channel_type = current_site.qrcode_channel_types.find(params[:id])

    if @qrcode_channel_type.update_attributes(params[:qrcode_channel_type])
      flash[:notice] = "编辑成功"
      render inline: "<script>window.parent.document.getElementById('weisiteModal').style.display='none';window.parent.location.reload();</script>"
    else
      flash[:alert] = "编辑失败"
      render :form, layout: 'application_pop'
    end
  end

  def destroy
    @qrcode_channel_type = current_site.qrcode_channel_types.find(params[:id])
    if @qrcode_channel_type.qrcode_channels.normal.count > 0
      redirect_to :back, alert: '有渠道在当前分类，不可删除'
    else
      if @qrcode_channel_type.deleted!
        redirect_to :back, notice: '删除成功'
      else
        redirect_to :back, alert: '删除失败'
      end
    end
  end

  private

  def mp_user_is_sync
    return redirect_to profile_path, alert: '服务号才有此功能' unless current_site.wx_mp_user.is_sync?
  end
end
