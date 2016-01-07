class Biz::VipGradesController < Biz::VipController
  before_filter :set_vip_card
  before_filter :find_vip_grade, only: [ :edit, :update, :destroy ]

  def index
    @vip_grades = @vip_card.vip_grades.visible.sorted.page(params[:page])
  end

  def new
    sort       = @vip_card.vip_grades.normal.maximum(:sort).to_i + 1
    @vip_grade = @vip_card.vip_grades.new(sort: sort, value: nil)
    render :form, layout: 'application_pop'
  end

  def edit
    render :form, layout: 'application_pop'
  end

  def save
    @vip_grade ||= @vip_card.vip_grades.new
    @vip_grade.attributes = params[:vip_grade]
    if @vip_grade.save
      flash[:notice] = "保存成功"
      render inline: "<script>window.parent.location.reload();</script>"
    else
      render_with_alert :form, "保存失败", layout: 'application_pop'
    end
  end

  alias create save
  alias update save

  def destroy
    return render js: 'showTip("warning", "操作失败： 该等级下已有会员存在");' if @vip_grade.vip_users.exists?
    if @vip_grade.update_attributes(status: VipGrade::DELETED)
      redirect_to vip_grades_path, notice: '操作成功'
    else
      redirect_to vip_grades_path, alert: "操作失败： #{@vip_grade.errors.full_messages.join("，")}"
    end
  end

  private
    def find_vip_grade
      @vip_grade = @vip_card.vip_grades.find(params[:id])
    end

end
