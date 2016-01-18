class Pro::CarCatenasController < ApplicationController
	before_filter :check_car_shop
  before_filter :find_car_cattena, only: [:edit, :update, :destroy]

	def index
		@search = @car_shop.car_catenas.order(:sort).search(params[:search])
		@car_catenas = @search.page(params[:page])
	end

	def new
		@car_catena = @car_shop.car_catenas.new
    render layout: 'application_pop'
	end

	def edit
    render layout: 'application_pop'
	end

  def create
    if params[:car_catena].present?
      params[:car_catena] = params[:car_catena].merge(car_brand_id: @car_shop.car_brand.try(:id))
      @car_catena = @car_shop.car_catenas.new(params[:car_catena])
      if @car_catena.save
        flash[:notice] =  "保存信息成功"
        render inline: "<script>window.parent.parent.location.reload()</script>"
      else
      	redirect_to :back, alert: "保存信息失败"
      end
    else
      redirect_to :back, alert: "保存信息失败"
    end
  end

  def update
    if params[:car_catena].present?
    	if @car_catena.update_attributes params[:car_catena]
    		flash[:notice] =  "保存信息成功"
        render inline: "<script>window.parent.parent.location.reload()</script>"
    	else
    		render :back, alert: "保存信息失败"
    	end
    else
      redirect_to :back, alert: "保存信息失败"
    end
  end

  def destroy
    if @car_catena.car_types.blank?
  	  @car_catena.destroy
  	  redirect_to car_catenas_path, notice: '删除成功'
    else
      redirect_to car_catenas_path, alert: "该车系下还有#{@car_catena.car_types.count}个车型,无法删除"
    end
  end

	private

  def find_car_cattena
    @car_catena = @car_shop.car_catenas.find_by_id(params[:id])
  end

	def check_car_shop
    @car_shop = current_site.car_shop
    return redirect_to car_shops_path, alert: '请先设置我的4S店' unless @car_shop
	end

end
