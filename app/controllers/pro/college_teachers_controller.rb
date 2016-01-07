class Pro::CollegeTeachersController < Pro::CollegesBaseController
  before_filter :find_college_teacher, only: [ :edit, :update, :destroy ]

  def index
    @search = @college.teachers.search(params[:search])
    @teachers = @search.order('id DESC').page(params[:page])
  end

  def new
    @teacher = CollegeTeacher.new
    render :form
  end

  def edit
    render :form
  end
  
  def save
    @teacher ||= @college.teachers.new
    @teacher.attributes = params[:college_teacher]
    if @teacher.save
      redirect_to college_teachers_path(@college), notice: "保存成功"
    else
      render_with_alert :form, "保存失败：#{@major.errors.full_messages.join('，')}"
    end
  end

  alias create save
  alias update save

  def destroy
    @teacher.destroy
    redirect_to college_teachers_path(@college), notice: "操作成功"
  end

  private
    def find_college_teacher
      @teacher = @college.teachers.find params[:id]
    end
end
