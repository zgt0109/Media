class Biz::WebsiteArticleCategoryTagsController < ApplicationController
  before_filter :set_website
  before_filter :set_categories
  before_filter :set_category
  before_filter :set_tag, only: [:edit, :update, :destroy, :update_sorts, :copy]
  
  def index
    @tags_all = @category.tags.order('tags.position DESC')
    @tags = @tags_all.page(params[:page]).per([params[:per].to_i, 10].max)
  end
  
  def new
    @tag = @category.tags.new
    @tagging = @tag.taggings.new(taggable_id: @category.id, taggable_type: @category.class.to_s)
    @children = @tag.children.new
  end

  def create
    @tag = Tag.new(params[:tag])
    if @tag.save
      redirect_to website_article_category_tags_path(category_type: params[:category_type], category_id: params[:category_id]), notice: '添加成功'
    else
      flash[:alert] = "添加失败: #{@tag.errors.full_messages.join(',')}"
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @tag.update_attributes(params[:tag])
      redirect_to website_article_category_tags_path(category_type: params[:category_type], category_id: params[:category_id]), notice: '保存成功'  
    else
      flash[:alert] = "保存失败: #{@tag.errors.full_messages.join(',')}"
      render action: 'edit'
    end
  end

  def destroy
    if @tag.destroy
      redirect_to :back, notice: '删除成功'
    else
      redirect_to :back, alert: "删除失败: #{@tag.errors.full_messages.join(',')}"
    end
  end

  def copy
    index = @tag.copys.collect(&:name).map{|f| f.split("#{@tag.name}副本").last }.compact.max.to_i + 1
    tag = Tag.new(copy_id: @tag.id, name: "#{@tag.name}副本#{index}")
    tag.taggings << @tag.taggings.new(taggable_id: @category.id, taggable_type: @category.class.to_s)
    @tag.children.each{|tc| tag.children << Tag.new(name: tc.name)}
    if tag.save
      redirect_to :back, notice: '复制成功'  
    else
      redirect_to :back, alert: "复制失败: #{tag.errors.full_messages.join(',')}"
    end
  end

  def update_sorts
    #1:置顶， -1:置底
    tags = @category.tags.order('tags.position DESC')
    index = tags.to_a.index(@tag)
    tags.each_with_index{|m, i| m.position = (tags.count - i)}
    if params[:type] == "up"
      return redirect_to :back, notice: '操作成功'  unless index - 1 >= 0
      tags[index].position, tags[index - 1].position =  tags[index - 1].position, tags[index].position
    elsif params[:type] == "down"
      return redirect_to :back, notice: '操作成功'  unless tags[index + 1]
      tags[index].position, tags[index + 1].position =  tags[index + 1].position, tags[index].position
    else
      sort_index = params[:index].to_i
      tags[index].position = tags[sort_index].position
      #靠后排
      if sort_index > index
        tags.each_with_index{|m, i| m.position = m.position - 1 if i <= sort_index && i > index}
        #靠前排
      elsif sort_index < index
        tags.each_with_index{|m, i| m.position = m.position + 1 if i >= sort_index && i < index}
      end
    end
    tags.each{|m| m.update_column('position', m.position) if m.position_changed?}
    redirect_to :back, notice: '操作成功'  
  end
  
  private

  def set_website
    @website = current_site.website
    return redirect_to websites_path, alert: '请先设置微官网' unless @website
  end
  
  def set_categories
    @categories = @website.categories.send(params[:category_type]).order(:position).root
    return redirect_to website_article_categories_path(category_type: params[:category_type]), alert: '请先添加分类' if @categories.blank?
  end
  
  def set_category
    if params[:category_id].present? 
      @category = @categories.where(id: params[:category_id]).first
    else
      @category = @categories.first
    end
    return redirect_to website_article_categories_path(category_type: params[:category_type]), alert: '分类不存在或已删除' unless @category
  end
  
  def set_tag
    @tag = @category.tags.where(id: params[:id]).first
    return redirect_to website_article_category_tags_path(category_type: params[:category_type], category_id: @category.id), alert: '分类不存在或已删除' unless @tag
  end

end
