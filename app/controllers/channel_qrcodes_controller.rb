class ChannelQrcodesController < ApplicationController
  before_filter :require_wx_mp_user#, :mp_user_is_sync

  def index
    @search = current_user.channel_qrcodes.normal.latest.search(params[:search])
    @channel_qrcodes = @search.page(params[:page])
    if params[:search]
      @type_id = params[:search][:channel_type_id_eq]
      @channel_way = params[:search][:channel_way_eq]
    end
  end

  def index_json
    # data = current_user.channel_qrcodes.normal.map do |qrcode|
    #   [qrcode.name, qrcode.channel_type.try(:name), qrcode.channel_way_name, qrcode.id]
    # end
    data = [ ["二维码1", "分类1", "线上", 1], 
              ["二维码2", "分类2", "线下", 2] ]
    render json: { aaData: data }
  end

  def new
    @channel_qrcode = current_user.channel_qrcodes.new
    render :form, layout: 'application_pop'
  end

  def edit
    @channel_qrcode = current_user.channel_qrcodes.find(params[:id])
    render :form, layout: 'application_pop'
  end

  def create
    scene_id = current_user.channel_qrcodes.maximum(:scene_id).to_i + 1
    @channel_qrcode = current_user.channel_qrcodes.new(params[:channel_qrcode].merge!(scene_id: scene_id))
    if @channel_qrcode.save
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
    @channel_qrcode = current_user.channel_qrcodes.find(params[:id])
    logo = params[:channel_qrcode][:logo] || "unchange"
    if @channel_qrcode.update_attributes(params[:channel_qrcode].merge!(logo: logo))
      flash[:notice] = "编辑成功"
      render inline: "<script>window.parent.document.getElementById('weisiteModal').style.display='none';window.parent.location.reload();</script>"
    else
      flash[:alert] = "编辑失败"
      render :form, layout: 'application_pop'
    end
  end

  def destroy
    @channel_qrcode = current_user.channel_qrcodes.find(params[:id])
    if @channel_qrcode.deleted!
      redirect_to :back, notice: '删除成功'
    else
      redirect_to :back, alert: '删除失败'
    end
  end

  def qrcode_download
    @channel_qrcode = current_user.channel_qrcodes.find(params[:id])
    render layout: 'application_pop'
  end

  def download
    @channel_qrcode = current_user.channel_qrcodes.find(params[:id])
    send_data @channel_qrcode.download(params[:type]), :disposition => 'attachment', :filename=>"winwemedia_#{@channel_qrcode.id}_#{params[:type]}.jpg"
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
    return redirect_to account_url, alert: '服务号才有此功能' unless current_user.wx_mp_user.is_sync?
  end
end
