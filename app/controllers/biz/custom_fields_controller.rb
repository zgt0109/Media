class Biz::CustomFieldsController < ApplicationController
  before_filter :fetch_field

  layout 'application_pop'

  def new
    if params[:customized_type] == 'Activity'
      @object = current_site.activities.find_by_id(params[:customized_id])
    else
      @object = current_site.vip_card
    end
    @new_field = CustomField.find_by_id(params[:field_id]) if params[:field_id]
  end

  def edit

  end

  def create
    field = CustomField.create!(params[:custom_field])
    if field
      flash[:notice] = "保存成功"
      if params[:has_next] == 'has_next'
        redirect_to action: :new, customized_id: field.customized_id, customized_type: field.customized_type, field_id: field.id
      else
        render inline: '<script>parent.document.location = parent.document.location;</script>';
      end
    else
      redirect_to :back, alert: '添加失败'
    end
  end

  def update
    if @field.update_attributes(params[:custom_field])
      flash[:notice] = "保存成功"
      if params[:has_next] == 'has_next'
        redirect_to action: :new, customized_id: @field.customized_id, customized_type: @field.customized_type, field_id: @field.id
      else
        render inline: '<script>parent.document.location = parent.document.location;</script>';
      end
    else
      redirect_to :back, alert: '添加失败'
    end
  end

  def toggle_editable
    @field.toggle! :editable
    render nothing: true
  end

  def toggle_visible
    @field.toggle! :visible
    render nothing: true
  end

  def toggle_captcha_required
    if @field.customized.is_a?(Activity)
      @field.customized.toggle_captcha_required!
    end
    render nothing: true
  end

  def toggle_is_required
    @field.toggle! :is_required
    render nothing: true
  end

  def destroy
    @field.deleted!
    redirect_to :back, notice: '删除成功'
  end

  def move_up
    @field.move_higher
    redirect_to :back, notice: '操作成功'
  end

  def move_down
    @field.move_lower
    redirect_to :back, notice: '操作成功'
  end

  def remove_option
    field = CustomField.find_by_id(params[:id])
    field.update_attributes(possible_values: params[:possible_values]) if field
    render nothing: true
  end


  private
  def fetch_field
    @field = CustomField.find_by_id(params[:id]) || CustomField.new
    @object = @field.customized if @field
  end
end
