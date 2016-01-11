class MaterialsController < ApplicationController
  # skip_filter :required_sign_in, only: [:show]

  before_filter :find_material, only: [:show, :edit, :update, :destroy]

  def index
    @materials = current_site.materials.single_graphic.graphic_select.page(params[:page]).order("id desc")
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @material.attributes.merge!({pic: {large: {url: @material.pic_url.to_s}}}).to_json }
    end
  end

  def new
    @material = Material.new
  end

  def create
    @material = current_site.materials.new(params[:material])

    respond_to do |format|
      if @material.save
        format.html { redirect_to materials_url, notice: '添加成功' }
        format.json { render action: 'show', status: :created, location: @material }
      else
        format.html { render action: 'new' }
        format.json { render json: @material.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @material.update_attributes(params[:material])
        format.html { redirect_to materials_url, notice: '保存成功' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @material.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @destroy_id = @material.id
    respond_to do |format|
      if @material.destroy
        format.html { redirect_to :back, notice: '删除成功' }
        format.js
      else
        format.html { redirect_to :back, alert: '删除失败' }
        format.js
      end
    end
  end

  private
    def find_material
      @material = current_site.materials.find(params[:id])
    rescue
      render text: '素材不存在'
    end

end
