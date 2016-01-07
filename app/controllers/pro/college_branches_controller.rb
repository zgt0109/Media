class Pro::CollegeBranchesController < Pro::CollegesBaseController
  before_filter :find_college_branch, only: [ :edit, :update, :destroy ]
  
  def index
    @branches = @college.branches.order('id DESC').page(params[:page])
    @branch   = params[:id] ? @college.branches.find(params[:id]) : CollegeBranch.new
    @form_url = @branch.new_record? ? college_branches_path(@college) : college_branch_path(@college, @branch)
  end

  def new
    @branch = CollegeBranch.new
    render :form, layout: 'application_pop'
  end

  def edit
    render :form, layout: 'application_pop'
  end

  def save
    @branch ||= @college.branches.new(supplier: current_user, wx_mp_user: current_user.wx_mp_user)
    @branch.attributes = params[:college_branch]
    if @branch.save
      flash.notice = "保存成功"
      render inline: "<script>parent.location.reload();</script>"
    else
      render_with_alert :form, "保存失败：#{@branch.errors.full_messages.join('，')}", layout: 'application_pop'
    end
  end

  alias create save
  alias update save
  
  def destroy
    @branch.destroy
    redirect_to intro_college_path(@college), notice: "操作成功"
  end

  private
    def find_college_branch
      @branch = @college.branches.find params[:id]
    end

end
