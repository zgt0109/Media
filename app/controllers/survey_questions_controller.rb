class SurveyQuestionsController < ApplicationController

  before_filter :set_activity, only: [:index, :new, :create, :edit, :update, :destroy, :update_sorts, :diagram]

  before_filter :set_survey_question, only: [:edit, :show, :update, :destroy, :update_sorts]


  def index
    @search = @activity.survey_questions.order(:position).search(params[:search])
    @survey_questions = @search.page(params[:page])
  end

  def show
    @avaliable_activities = current_site.activities.surveys.setting
    @avaliable_activities = @avaliable_activities.where(id: params[:activity_id]) if params[:activity_id]
  end

  def new
    @survey_question = @activity.survey_questions.new
  end

  def create
    @survey_question = SurveyQuestion.new(params[:survey_question])
    if @survey_question.save
      redirect_to survey_questions_path(activity_id: @activity.id), notice: '保存成功'
    else
      redirect_to :back, alert: '保存失败'
    end
  end

  def edit
  end

  def update
    if @survey_question.update_attributes(params[:survey_question])
      redirect_to survey_questions_path(activity_id: @activity.id), notice: '保存成功'
    else
      redirect_to :back, alert: '保存失败'
    end
  end

  def destroy
    if @survey_question.destroy
      redirect_to :back, notice: '删除成功'
    else
      redirect_to :back, alert: "删除失败：#{@activity.full_error_message}"
    end
  end

  def diagram
    @survey_questions = @activity.survey_questions.order(:position).page(params[:page])
    @activity_type_id = 15
  end

  def user_data
    @search = current_site.activity_users.survey_finish.joins(:activity).includes(:activity_feedback).where("activities.activity_type_id = 15 AND activities.status > -2").order('activity_users.id DESC').search(params[:search])
    @activity_users = @search.page(params[:page])
    @total_count = @search.count

    activity_id = params[:search][:activity_id_eq] rescue nil
    @activity = current_site.activities.surveys.find activity_id if activity_id.present?

    respond_to do |format|
      format.html
      format.xls { render_404 unless @activity }
    end
  end

  def update_sorts
    if params[:type] == "up"
      @survey_question.move_higher
    elsif params[:type] == "down"
      @survey_question.move_lower
    end
    redirect_to :back, notice: '操作成功'
  end

  private

  def set_activity
    @activity = current_site.activities.surveys.find(params[:activity_id])
  end

  def set_survey_question
    return render_404 unless @activity
    @survey_question = @activity.survey_questions.find(params[:id])
    return redirect_to survey_questions_path(activity_id: @activity.id), alert: '题目不存在或已删除' unless @survey_question
  end



  def xls_content_for(objs = [], options = {})
    question_names = objs.first.try(:activity).try(:survey_questions).try(:collect,&:name) || []
    activity_enrolls__report = StringIO.new

    Spreadsheet.client_encoding = options[:client_encoding] || "UTF-8"

    book = Spreadsheet::Workbook.new

    sheet1 = book.create_worksheet :name => "微调研用户数据"

    sheet1.row(0).default_format = nil

    sheet1.row(0).concat ["序号","姓名","手机号",question_names,"建议","调研时间"].flatten

    row = 1
    objs.each_with_index do |obj, index|
      sheet1[row, 0] = index + 1
      sheet1[row, 1] = obj.name.present? ? obj.name : '匿名用户'
      sheet1[row, 2] = obj.mobile.present? ? obj.mobile : '匿名用户'
      num = 3
      obj.try(:activity).try(:survey_questions).each_with_index do |question,index|
        answers = []
        question.survey_answers.where(activity_user_id: obj.id).each{|a| a.answer == "其他" ? answers << "其他："+a.summary : answers << ("选项"+a.answer)}
        sheet1[row, (index+3)] = answers.join("  |  ")
        num += 1
      end
      sheet1[row, num] = obj.feedback.try(:content)
      sheet1[row, (num+1)] = obj.created_at
      row += 1
    end

    book.write activity_enrolls__report
    activity_enrolls__report.string
  end


end