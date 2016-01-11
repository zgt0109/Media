class Mobile::HospitalCommentsController < Mobile::BaseController
  layout "mobile/hospital"

  before_filter :set_doctor_and_comments, only: [:index, :create, :new]

  def index
    @page_class = "detail"    
  end
  
  def new
    @page_class = "detail"
    @hospital_comment = @hospital_doctor.hospital_comments.new
  end

  def create
    @hospital_comment = @hospital_doctor.hospital_comments.new(params[:hospital_comment])
    if @hospital_comment.save
      redirect_to new_mobile_hospital_comment_path(site_id: @site.id, id: @hospital_doctor.id), notice: "评论成功"
    else
      render :back, notice: "评论失败"
    end
  end

  def set_doctor_and_comments
    @user = User.find(session[:user_id])
    @hospital = @site.hospital
    @hospital_doctor = @hospital.hospital_doctors.find(params[:id])
    @hospital_comments = @hospital_doctor.hospital_comments.order("created_at desc")
  end

end

