class Pro::CollegeMajorsController < Pro::CollegesBaseController
  before_filter :find_college_major, only: [ :edit, :update, :destroy ]
  def index
    @search = @college.majors.search(params[:search])
    @majors = @search.order('id DESC').page(params[:page])
  end

  def new
    @major = CollegeMajor.new
    render :form
  end

  def edit
    render :form
  end

  def save
    @major ||= @college.majors.build
    @major.attributes = params[:college_major]
    if @major.save
      redirect_to college_majors_path(@college), notice: "保存成功"
    else
      render_with_alert :form, "保存失败：#{@major.errors.full_messages.join('，')}"
    end
  end

  alias create save
  alias update save

  def destroy
    return redirect_to college_majors_path(@college), alert: "该专业已有学生报名，无法删除" if @major.college_enrolls.exists?
    @major.destroy
    redirect_to college_majors_path(@college), notice: "操作成功"  
  end

  private
    def find_college_major
      @major = @college.majors.find params[:id]
    end
end
