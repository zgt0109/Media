class QuestionsController < ApplicationController
  before_filter :set_question, only: [:show, :edit, :update, :destroy]

  def index
    return redirect_to wx_mp_users_path, alert: '请先添加微信公共帐号' unless current_user.wx_mp_user

    @search = current_user.questions.order('created_at DESC').search(params[:search])
    @questions = @search.page(params[:page])
  end

  def new
    @question = current_user.questions.new
    render layout: 'application_pop'
  end

  def create
    @question = current_user.questions.new(params[:question])
    if @question.save
      flash[:notice] = '添加成功'
      render inline: "<script>window.parent.location.href = '#{questions_path}';</script>"
    else
      flash[:alert] = "添加失败"
      render action: 'new', layout: 'application_pop'
    end
  end

  def edit
    render layout: 'application_pop'
  end

  def update
    if @question.update_attributes(params[:question])
      flash[:notice] = '保存成功'
      render inline: "<script>window.parent.location.href = '#{questions_path}';</script>"
    else
      flash[:alert] = "保存失败"
      render action: 'edit', layout: 'application_pop'
    end
  end

  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to questions_path, notice: '删除成功' }
      format.json { head :no_content }
    end
  end

  def destroy_multi
    if params[:ids].present?
      current_user.questions.where(id: params[:ids]).delete_all
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, notice: '请先选中需要删除的关键词'
    end
  end

  private
    def set_question
      @question = current_user.questions.find(params[:id])
    end

end
