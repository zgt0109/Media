class MultipleMaterialsController < ApplicationController
  # skip_filter :required_sign_in, only: [:show]
  before_filter :find_material, only: [:show, :edit, :update, :destroy]

  before_filter do
    @partialLeftNav = "/layouts/partialLeftWeixin"
  end

  def index
    @materials = current_site.materials.root.multiple_graphic.graphic_select.page(params[:page]).order("id desc")
  end

  def show
    respond_to do |format|
      format.html { redirect_to edit_multiple_material_url(@material) }
      format.json { render json: @material.to_json }
    end
  end

  def new
    @material = current_site.materials.new(material_type: 2)
    @material.children.build(site_id: current_site.id, material_type: 2, title: '标题')
  end

  def create
    @material = current_site.materials.new(params[:material])

    if @material.save
      @material.children.create(params[:materials])

      if @material.children.count == 0
        redirect_to edit_multiple_material_url(@material), alert: '建议多图文至少2条图文消息'
      else
        #redirect_to multiple_materials_url, notice: '添加成功'
        redirect_to edit_multiple_material_url(@material), notice: '添加成功'
      end
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @material.update_attributes(params[:material])
      @material.children.create(params[:materials])

      #remove child material needed to be destroy
      children_attributes = params[:material][:children_attributes]
      children_attributes.to_a.each do |index, children_attribute|
        if !children_attribute.has_key?('title') && children_attribute.has_key?('id')
          id = children_attribute.fetch('id')
          Material.destroy(id)
        end
      end

      if @material.children.count == 0
        redirect_to edit_multiple_material_url(@material), alert: '建议多图文至少2条图文消息'
      else
        #redirect_to multiple_materials_url, notice: '保存成功'
        redirect_to :back, notice: '保存成功'
      end
    else
      render action: 'edit'
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
      @material = current_site.materials.multiple_graphic.where(id: params[:id]).first
      return render text: '素材不存在' unless @material
    end

end
