class Pro::StandalonePanoramasController < Pro::HousesBaseController
  before_filter :find_house, except: [:info]
  after_filter :notify_standalone_panorama, only: [:create, :update]
  skip_before_filter *ADMIN_FILTERS, :set_current_user, :promotion_code_tracking, :bqq_auth,:require_wx_mp_user, :require_industry, :require_house, only: [:info]

  def new
    @house_layout = HouseLayout.find params[:house_layout_id]
    @standalone_panorama = @house_layout.standalone_panoramas.new
  end

  def create
    @house_layout = HouseLayout.find params[:house_layout_id]
    @standalone_panorama = @house_layout.standalone_panoramas.new params[:standalone_panorama]

    if @standalone_panorama.save
      redirect_to house_layout_house_layout_panoramas_path(@house_layout), notice: "保存成功"
    else
      flash[:alert] = "保存失败"
      redirect_to house_layout_house_layout_panoramas_path(@house_layout)
    end
  end

  def edit
    @house_layout = HouseLayout.find params[:house_layout_id]
    @standalone_panorama = @house_layout.standalone_panoramas.find params[:id]
  end

  def update
    @house_layout = HouseLayout.find params[:house_layout_id]
    @standalone_panorama = @house_layout.standalone_panoramas.find params[:id]
    if @standalone_panorama.update_attributes params[:standalone_panorama]
      redirect_to house_layout_house_layout_panoramas_path(@house_layout), notice: "全景图保存成功"
    else
      redirect_to :back, alert: "全景图保存出错"
    end
  end

  def info
    origin_file_url, preview_url = params[:origin_file_url], params[:preview_url]
    @standalone_panoramas = StandalonePanorama.where(file_url: origin_file_url)
    if @standalone_panoramas.present?
      @standalone_panoramas.each{|p| p.update_attributes preview_url: preview_url }
      render json: {message: 'successed'}
    else
      render json: {message: 'failed'}
    end
  end

  def destroy
    @house_layout = HouseLayout.find params[:house_layout_id]
    @standalone_panorama = @house_layout.standalone_panoramas.find params[:id]
    @standalone_panorama.destroy
    redirect_to house_layout_house_layout_panoramas_path(@house_layout)
  end

  private
  def find_house
    @house = current_user.house
  end

  def notify_standalone_panorama
    send_mq_message "standalone_panorama" do |queue|
      mq_message_content = {file_url: @standalone_panorama.file_url, timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S %N")}.to_yaml
      logger.info "send mq message for standalone panorama: #{mq_message_content}"
      queue.publish(mq_message_content)
    end
  end
end
