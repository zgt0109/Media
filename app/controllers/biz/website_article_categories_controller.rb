class Biz::WebsiteArticleCategoriesController < ApplicationController
  before_filter :require_wx_mp_user
  before_filter :set_website
  before_filter :set_categories, only: [:index, :new, :create, :edit, :update]
  before_filter :set_category, only: [:edit, :update, :destroy, :update_sorts, :copy]

  def index
  end

  def new
    @category = @website.categories.send(params[:category_type]).new(parent_id: params[:parent_id].to_i, category_type:  WebsiteArticleCategory.const_get(params[:category_type].upcase))
  end

  def create
    @category = WebsiteArticleCategory.new(params[:website_article_category])
    if @category.save
      if params[:submit_type].to_i == 1
        redirect_to website_article_category_tags_path(category_type: params[:category_type], category_id: @category.id)  
      else
        redirect_to website_article_categories_path(category_type: params[:category_type]), notice: '添加成功'  
      end
    else
      flash[:alert] = "添加失败: #{@category.errors.full_messages.join(',')}"
      render action: 'new'
    end
  end
  
  def edit
  end

  def update
    if @category.update_attributes(params[:website_article_category])
      if params[:submit_type].to_i == 1
	redirect_to website_article_category_tags_path(category_type: params[:category_type], category_id: @category.id)  
      else
        redirect_to website_article_categories_path(category_type: params[:category_type]), notice: '保存成功'  
      end
    else
      flash[:alert] = "保存失败: #{@category.errors.full_messages.join(',')}"
      render action: 'edit'
    end
  end

  def destroy
    if @category.destroy
      redirect_to :back, notice: '删除成功'
    else
      redirect_to :back, alert: "删除失败: #{@category.errors.full_messages.join(',')}"
    end
  end

  def copy
    if @category.copy_self
      redirect_to :back, notice: '复制成功'
    else
      redirect_to :back, alert: "复制失败: #{@category.errors.full_messages.join(',')}"
    end
  end

  def update_sorts
    if params[:type] == "up"
      @category.move_higher
    elsif params[:type] == "down"
      @category.move_lower
    end
    render json: {result: 'success', id: @category.id}
  end

  private

  def set_website
    @website = current_user.website
    return redirect_to websites_path, alert: '请先设置微官网' unless @website
  end

  def set_categories
    @categories = @website.categories.send(params[:category_type])
  end

  def set_category
    @category = @website.categories.send(params[:category_type]).where(id: params[:id]).first
    return redirect_to website_article_categories_path, alert: '分类不存在或已删除' unless @category
  end

end
