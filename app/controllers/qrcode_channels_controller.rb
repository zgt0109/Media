class QrcodeChannelsController < ApplicationController

  def index
    @search = current_site.qrcode_channels.normal.latest.search(params[:search])
    @qrcode_channels = @search.page(params[:page])
    if params[:search]
      @type_id = params[:search][:qrcode_channel_type_id_eq]
      @channel_way = params[:search][:channel_way_eq]
    end
  end

  def index_json
    # data = current_site.qrcode_channels.normal.map do |qrcode|
    #   [qrcode.name, qrcode.qrcode_channel_type.try(:name), qrcode.channel_way_name, qrcode.id]
    # end
    data = [ ["二维码1", "分类1", "线上", 1], 
              ["二维码2", "分类2", "线下", 2] ]
    render json: { aaData: data }
  end

  def new
    @qrcode_channel = current_site.qrcode_channels.new
    render :form, layout: 'application_pop'
  end

  def edit
    @qrcode_channel = current_site.qrcode_channels.find(params[:id])
    render :form, layout: 'application_pop'
  end

  def create
    scene_id = current_site.qrcode_channels.maximum(:scene_id).to_i + 1
    @qrcode_channel = current_site.qrcode_channels.new(params[:qrcode_channel].merge!(scene_id: scene_id))
    if @qrcode_channel.save
      flash[:notice] = "添加成功"
      render inline: "<script>window.parent.document.getElementById('weisiteModal').style.display='none';window.parent.location.reload();</script>"
    else
      flash[:alert] = "添加失败"
      render :form, layout: 'application_pop'
    end
  rescue => e
    flash[:notice] = "无法使用，您的公众账号没有开通高级接口"
    render inline: "<script>window.parent.document.getElementById('weisiteModal').style.display='none';window.parent.location.reload();</script>"
  end

  def update
    @qrcode_channel = current_site.qrcode_channels.find(params[:id])
    logo = params[:qrcode_channel][:logo] || "unchange"
    if @qrcode_channel.update_attributes(params[:qrcode_channel].merge!(logo: logo))
      flash[:notice] = "编辑成功"
      render inline: "<script>window.parent.document.getElementById('weisiteModal').style.display='none';window.parent.location.reload();</script>"
    else
      flash[:alert] = "编辑失败"
      render :form, layout: 'application_pop'
    end
  end

  def destroy
    @qrcode_channel = current_site.qrcode_channels.find(params[:id])
    if @qrcode_channel.deleted!
      redirect_to :back, notice: '删除成功'
    else
      redirect_to :back, alert: '删除失败'
    end
  end

  def qrcode_download
    @qrcode_channel = current_site.qrcode_channels.find(params[:id])
    render layout: 'application_pop'
  end

  def download
    @qrcode_channel = current_site.qrcode_channels.find(params[:id])
    send_data @qrcode_channel.download(params[:type]), :disposition => 'attachment', :filename=>"winwemedia_#{@qrcode_channel.id}_#{params[:type]}.jpg"
  end

  def load_logo(file)
    if file.present?
      path = File.join(Rails.root.to_s, "public", "qrcode_logo", file.original_filename)
      File.open(path , "wb") do |f|
        f.write(file.read)
      end
    end
    return path
  end

  private

  def mp_user_is_sync
    return redirect_to profile_path, alert: '服务号才有此功能' unless current_site.wx_mp_user.is_sync?
  end
end
