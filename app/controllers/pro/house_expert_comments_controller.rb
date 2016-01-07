class Pro::HouseExpertCommentsController < ApplicationController

  layout 'application_gm'

  def index
    @house = current_user.house
    return redirect_to houses_path, alert: '请先添加楼盘信息' unless @house

    @total_house_expert_comments = @house.house_expert_comments.normal
    @search = @total_house_expert_comments.search(params[:search]).order("created_at desc")
    @house_expert_comments = @search.page(params[:page])

    @house_expert_comment = @total_house_expert_comments.where("id = ?", params[:id]).first || @total_house_expert_comments.new(house_id: @house.id)
  end

  def show
    @house_expert_comment = HouseExpertComment.find(params[:id])
  end

  def new
    @house_expert_comment = HouseExpertComment.new
  end

  def edit
    @house_expert_comment = HouseExpertComment.find(params[:id])
  end

  def create
    @house_expert_comment = HouseExpertComment.new(params[:house_expert_comment])

    respond_to do |format|
      if @house_expert_comment.save
        format.html { redirect_to :back, notice: '点评添加成功' }
      else
        format.html { redirect_to :back, notice: '添加失败' }
      end
    end
  end

  def update
  	@house = current_user.house
    return redirect_to houses_path, alert: '请先添加楼盘信息' unless @house
    @house_expert_comment = current_user.house.house_expert_comments.find(params[:id])

    respond_to do |format|
      if @house_expert_comment.update_attributes(params[:house_expert_comment])
        format.html { redirect_to house_expert_comments_url, notice: '修改成功' }
      else
        format.html { redirect_to :back, notice: '修改失败' }
      end
    end
  end

  def destroy
  	@house = current_user.house
    return redirect_to houses_path, alert: '请先添加楼盘信息' unless @house
    @house_expert_comment = current_user.house.house_expert_comments.normal.find(params[:id])
    respond_to do |format|
    	if @house_expert_comment and  @house_expert_comment.delete!
      	format.html { redirect_to :back, notice: '删除成功' }
     	else
     		format.html { redirect_to :back, notice: '删除失败' }
      end
    end
  end
end
