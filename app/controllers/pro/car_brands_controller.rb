class Pro::CarBrandsController < ApplicationController
	# before_filter :check_car_shop
  layout "application_gm"

  def index
    # @car_brands = current_site.car_brands.normal
    @car_brands = [current_site.car_brand]
    @car_brand = CarBrand.new(site_id: current_site.id)
  end

  def edit
    # @car_brand = current_site.car_brands.find(params[:id])
    @car_brand = current_site.car_brand
  end

  def create
    # return redirect_to :back, notice: '此品牌名称已经存在' if current_site.car_brands.normal.where(name: params[:car_brand][:name]).count>0
    return redirect_to :back, notice: '此品牌名称已经存在' if current_site.car_brand.try(:name) == params[:car_brand][:name]
    @car_brand = current_site.build_car_brand.attributes = params[:car_brand]
    respond_to do |format|
      if @car_brand.save
        format.html { redirect_to :back, notice: '添加成功' }
      else
        format.html { redirect_to :back, notice: '添加失败' }
      end
    end
  end

  def update
    # @car_brand = current_site.car_brands.find(params[:id])
    @car_brand = current_site.car_brand
    respond_to do |format|
      if @car_brand.update_attributes(params[:car_brand])
        format.html { redirect_to @car_brand, notice: '保存成功' }
      else
        format.html { render action: "edit" }
      end
    end
  end
  
  def destroy
    # @car_brand = current_site.car_brands.normal.find(params[:id])
    @car_brand = current_site.car_brand
    respond_to do |format|
      if @car_brand.delete!
        format.html { redirect_to :back, notice: '删除成功' }
      else
        format.html { redirect_to :back, notice: '删除失败' }
      end
    end
  rescue => error
    return redirect_to :back, notice: '删除失败'
  end

	private
	def check_car_shop
    @car_shop = current_site.car_shop
    return redirect_to car_shops_path, notice: '请先设置我的4S店' unless @car_shop
	end
end
