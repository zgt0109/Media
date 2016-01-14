module App
  class CollegeTeachersController < BaseController

    layout 'app/educations'
    before_filter :find_college


    def index
      @teachers = @college.teachers
    end

    def show
      @teacher = CollegeTeacher.find_by_id(params[:id])
      unless @teacher.present?
        redirect_to app_college_teachers_url, :notice => "数据出错！"
      end
    end

    private

    def find_college
      session[:cid] = params[:cid] if params[:cid].present?

      @college  = College.includes(:majors).find(params[:cid] || session[:cid])
      @college_enroll ||= @college.enrolls.new(user_id: session[:user_id])
    rescue
      return render text: '请求参数不正确'
    end

  end
end
