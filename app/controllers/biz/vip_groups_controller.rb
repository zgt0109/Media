class Biz::VipGroupsController < Biz::VipController
  before_filter :find_vip_groups, only: [:index, :add_to_group, :create, :update, :destroy, :remove_user_group_id]
  PAGE_SIZE = 24

  def index
    @search = current_user.vip_users.visible.name_like(params[:name]).by_group(params[:group])
    @search = @search.includes(:vip_grade, :vip_group, :custom_values).by_grade(params[:grade])
    @vip_users = @search.page(params[:page]).per(PAGE_SIZE)
    @vip_grades = current_user.vip_card.vip_grades.visible.sorted
  end

  def search_user
    @vip_users = current_user.vip_users.visible.name_like(params[:name]).by_group(params[:group])
    @vip_users = @vip_users.includes(:vip_grade, :vip_group).page(params[:page]).per(PAGE_SIZE)
  end

  def search_grade
    @vip_users = current_user.vip_users.visible.by_group(params[:group]).includes(:vip_grade).by_grade(params[:grade])
    @vip_users = @vip_users.page(params[:page]).per(PAGE_SIZE)
  end

  def search_custom_value
    @vip_users = current_user.vip_users.visible.by_group(params[:group]).includes(:vip_grade)
    @vip_users = @vip_users.by_custom_field(params[:custom_field_id], params[:custom_value])
    @vip_users = @vip_users.page(params[:page]).per(PAGE_SIZE)
  end

  def change_group
    @vip_users = current_user.vip_users.visible.includes(:custom_values).by_group(params[:group])
    @vip_users = @vip_users.includes(:vip_grade, :vip_group).page(params[:page]).per(PAGE_SIZE)
  end

  def add_to_group
    vip_group_id = params[:group] == '-2' ? nil : params[:group]
    vip_users = current_user.vip_users.visible.where(id: params[:ids])
    # vip_users.update_all(vip_group_id: vip_group_id)
    VipUser.update(params[:ids], [{vip_group_id: vip_group_id}]*(params[:ids]).count)
    vip_users_count = current_user.vip_users.visible.where(vip_group_id: vip_group_id).count
    current_user.vip_card.vip_groups.where(id: vip_group_id).update_all(vip_users_count: vip_users_count)
    @search = current_user.vip_users.visible.by_group(params[:origin_group])
    @vip_users = @search.page(params[:page]).per(PAGE_SIZE)
  end

  def create
    @group = @vip_groups.create(name: params[:name])
  end

  def update
    @group = @vip_groups.find params[:id]
    @group.update_attributes(name: params[:name])
  end

  def destroy
    @vip_groups.find(params[:id]).destroy
  end

  def remove_user_group_id
    @vip_user = current_user.vip_users.visible.find params[:id]
    @vip_group_id = @vip_user.vip_group_id
    @vip_user.update_attributes(vip_group_id: nil)
    @search = current_user.vip_users.visible.where(vip_group_id: @vip_group_id)
    @vip_users = @search.page(params[:page]).per(PAGE_SIZE)
  end

  private
  def find_vip_groups
    @vip_groups = current_user.vip_card.vip_groups
  end

end
