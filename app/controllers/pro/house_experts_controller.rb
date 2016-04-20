class Pro::HouseExpertsController < ApplicationController
  layout 'application_gm'

  def index
    @house = current_site.house
    return redirect_to houses_path, alert: '请先添加楼盘信息' unless @house

    @total_house_experts = @house.house_experts.normal
    @search = @total_house_experts.search(params[:search])
    @house_experts = @search.page(params[:page])

    @house_expert = @total_house_experts.where("id = ?", params[:id]).first || @total_house_experts.new(site_id: current_site.id)
  end

  def show
    @house_expert = HouseExpert.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @house_expert }
    end
  end

  def new
    @house_expert = HouseExpert.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @house_expert }
    end
  end

  def edit
    @house_expert = HouseExpert.find(params[:id])
  end

  def create
    @house_expert = HouseExpert.new(params[:house_expert])

    respond_to do |format|
      if @house_expert.save
        format.html { redirect_to :back, notice: '专家添加成功' }
      else
        format.html { redirect_to :back, notice: '添加失败' }
      end
    end
  end

  def update
  	@house = current_site.house
    return redirect_to houses_path, alert: '请先添加楼盘信息' unless @house
    @house_expert = current_site.house.house_experts.find(params[:id])

    respond_to do |format|
      if @house_expert.update_attributes(params[:house_expert])
        format.html { redirect_to house_experts_url, notice: '修改成功' }
      else
        format.html { redirect_to :back, notice: '修改失败' }
      end
    end
  end

  def destroy
  	@house = current_site.house
    return redirect_to houses_path, alert: '请先添加楼盘信息' unless @house
    @house_expert = current_site.house.house_experts.find(params[:id])
    respond_to do |format|
    	if @house_expert and @house_expert.delete!
    		format.html { redirect_to :back, notice: '删除成功' }
    	else
    		format.html { redirect_to :back, notice: '删除失败' }
    	end
    end
  end
end
