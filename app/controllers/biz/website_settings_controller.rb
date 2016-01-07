class Biz::WebsiteSettingsController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:set_template_id, :update_update_nav_template]
  before_filter :require_wx_mp_user
  before_filter :find_website

  def index    
    @website_tags = WebsiteTag.order(:sort) #if @use_website_tag
    if [10001,10002].include?(current_user.id)
      @website_templates = WebsiteTemplate.order('website_templates.style_index DESC')
    else
      @website_templates = WebsiteTemplate.show.supplier_templates(current_user).order('website_templates.style_index DESC')
    end
  end

  def set_template_id
    website_setting_id, template_id, template_type = params[:website_setting_id].to_i, params[:template_id].to_i, params[:template_type].to_i
    website_setting = WebsiteSetting.where(id: website_setting_id).first
    website_setting && website_setting.set_template(template_id, template_type)
    render :json => {template_id: template_id}
  end

  def update
    respond_to do |format|
      if @website_setting.update_attributes(params[:website_setting])
        format.html { redirect_to :back, notice: '保存成功' }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, notice: '保存失败' }
        format.json { render json: @website.errors, status: :unprocessable_entity }
      end
    end
  end

  def bg_pic
  end

  def navs
    @nav_type_columns = {
      1 => 'index_nav_template_id',
      2 => 'nav_template_id'
    }
    @website_templates = WebsiteTemplate.where(["template_type = ? and style_index <> 14", WebsiteTemplate::NAVIGATION]).order(:style_index)

    @bqq_website = false
    @bqq_style_index = []
    if current_user.bqq_account?
      @bqq_style_index = current_user.bqq_website_product[4] || []
      @bqq_website = true
    end

    render layout: 'application_pop'
  end

  def update_bg_pic
    respond_to do |format|
      if @website_setting.update_attributes(params[:website_setting])
        format.html { redirect_to :back, notice: '保存成功' }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, notice: '保存失败' }
        format.json { render json: @website_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  def change_article_sort
    if @website_setting.update_attributes(params[:column] => params[:value])
      render json: {result: 'success', id: @website_setting.id}  
    else
      render json: {result: 'failure', err_msg: @website_setting.errors.full_messages.join(',')} 
    end
  end

  def update_update_nav_template
    errors = []
    errors << "缺少模版类型参数 nav_type" unless params[:nav_type].to_i > 0
    errors << "无法获取 website_setting 对象" unless @website_setting
    if errors.blank?
      attr_name = (params[:nav_type].to_i == 1 && :index_nav_template_id || :nav_template_id)
      @website_setting.update_attribute(attr_name, params[:nav_template_id].to_i)
      @website.website_popup_menus_initialize(params[:nav_type].to_i) if @website.website_popup_menus.where(nav_type: params[:nav_type].to_i).count == 0 && @website.nav_menus_default_datas.keys.include?(params[:nav_template_id].to_i)
    end
    render :json => {errors: errors, nav_type: params[:nav_type].to_i, website_setting_id: @website_setting.id}
  end

  private

  def find_website
    @website = current_user.website
    return redirect_to websites_path, alert: '请先设置微官网' unless @website
    @website_setting = @website.website_setting ||= @website.create_default_setting
  end

end
