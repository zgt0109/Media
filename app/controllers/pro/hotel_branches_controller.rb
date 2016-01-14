class Pro::HotelBranchesController < Pro::HotelsBaseController
  before_filter :check_hotel
  before_filter :set_hotel_branch, only: [:show, :edit, :update, :destroy]

  def index
    @total_hotel_branches = @hotel.hotel_branches.normal.order("is_default desc,created_at desc")
    @search = @total_hotel_branches.search(params[:search])
    @hotel_branches = @search.page(params[:page])
  end

  def new
    @hotel_branch = @hotel.hotel_branches.new(site_id: current_site.id)
  end

  def edit
  end


  def create
    @hotel_branch = @hotel.hotel_branches.new(params[:hotel_branch])
    respond_to do |format|
      if @hotel_branch.save
        cancel_branch_default(@hotel_branch)
        format.html { redirect_to hotel_branches_path, notice: '添加成功' }
      else
        format.html { redirect_to :back, alert: '添加失败' }
      end
    end
  end

  def update
    respond_to do |format|
      if @hotel_branch.update_attributes(params[:hotel_branch])
        cancel_branch_default(@hotel_branch)
        format.html { redirect_to hotel_branches_path, notice: '保存成功' }
      else
        format.html { redirect_to :back, alert: '保存失败' }
      end
    end
  end

  def destroy
    return redirect_to :back, alert: '分店下面有房型，不能删除分店' if @hotel_branch.hotel_room_types.normal.count > 0
    respond_to do |format|
      if @hotel_branch.delete!
        format.html { redirect_to :back, notice: '删除成功' }
      else
        format.html { redirect_to :back, alert: '删除失败' }
      end
    end
  rescue => error
		return redirect_to :back, alert: '删除失败'
  end

  def cancel_branch_default(branch)
    @hotel.hotel_branches.where('id != ?', branch.id).update_all(is_default: false) if branch.default?
  end


  def set_hotel_branch
    @hotel_branch = @hotel.hotel_branches.where(id: params[:id]).first
    return redirect_to hotel_branches_path, alert: '分店不存在或已删除' unless @hotel_branch
  end

end

