class FightQuestionsController < ApplicationController

  before_filter :restrict_trial_supplier

  def index
    @search = scoped_questions.used.search(params[:search])
    @fight_questions = @search.page(params[:page]).per(18).order('created_at desc')
  end

  def show
    @fight_question = scoped_questions.find(params[:id])
  end

  def new
    @fight_question = scoped_questions.new
    render :form
  end

  def edit
    @fight_question = scoped_questions.find(params[:id])
    render :form
  end

  def create
    @fight_question = scoped_questions.new(params[model_name])
    respond_to do |format|
      if @fight_question.save
        format.html { redirect_to index_path, notice: '题目添加成功' }
      else
        format.html { render action: "index" }
      end
    end
  end

  def update
    @fight_question = scoped_questions.find(params[:id])
    respond_to do |format|
      if @fight_question.update_attributes(params[model_name])
        format.html { redirect_to index_path, notice: '保存成功' }
      else
        format.html { render action: "index" }
      end
    end
  end

  def destroy
    @fight_question = scoped_questions.find(params[:id])
    if @fight_question.fight_paper_questions.count == 0
      if @fight_question.delete!
        redirect_to :back, notice: '删除成功'
      else
        redirect_to :back, alert: "删除失败，#{@fight_question.errors.full_messages.join(', ')}"
      end
    else
      redirect_to :back, notice: '已使用中,不能删除!'
    end
  end

  private
    def index_path
      fight_questions_path
    end

    def scoped_questions
      current_user.fight_questions
    end

    def model_name
      :fight_question
    end
end
