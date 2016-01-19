class Pro::HospitalsController < Pro::HospitalBaseController
  skip_before_filter :require_hospital, only: [:index]
  before_filter :set_hospital

  def index
    return redirect_to wx_mp_users_path, alert: '请先添加微信公共帐号' unless current_site.wx_mp_user
    @activity = @hospital.activity
  end

  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @hospital }
    end
  end

  def edit
  end

  def create
    respond_to do |format|
      if @hospital.save
        format.html { redirect_to @hospital, notice: 'Ec shop was successfully created.' }
        format.json { render json: @hospital, status: :created, location: @hospital }
      else
        format.html { render action: "new" }
        format.json { render json: @hospital.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @hospital.update_attributes(params[:hospital])
        format.html { redirect_to :back, notice: '保存成功' }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, notice: '保存失败' }
        format.json { render json: @hospital.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @hospital.clear_menus!
      redirect_to :back
    else
      redirect_to :back, notice: '操作失败'
    end
  end

  private

  def set_hospital
    @hospital = current_site.hospital
    @hospital = current_site.create_hospital unless @hospital
  end
  
end
