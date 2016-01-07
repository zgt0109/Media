class Biz::WebsiteArticlesController < ApplicationController
  
  before_filter :require_wx_mp_user, :set_website
  before_filter :find_article, only: [:edit, :update, :destroy, :edit_pic, :update_pic, :delete_pic, :update_sort, :change_is_top]

	def index
		params[:article_type] ||= "as_article"
		@categories = @website.categories.send(params[:article_type])
                @category = @categories.where(id: params[:category_id]).first if params[:category_id].present?
		@per_page = (params[:per_page].presence || 10).to_i
		@search = @website.website_articles.send(params[:article_type]).categorized(@category).latest.search(params[:search])
		@website_articles = @search.page([params[:page].to_i,1].max).per(@per_page)
	end

	def new
		@tag_children_ids = []
		@descriptions = []
		@article = @website.website_articles.new(article_type: params[:article_type] == "as_article" ? 2 : 3)
    render :form
	end

	def edit
		@tag_children_ids = @article.tags.tag_children.pluck(:id)
		@descriptions = @tag_children_ids.collect do |id|
			@article.taggings.where(tag_id: id).first.description
		end
		render :form
	end

	def create
    @article = @website.website_articles.new(params[:website_article].merge!(supplier_id: @website.supplier_id, wx_mp_user_id: @website.wx_mp_user_id))
    if @article.save
    	save_article_tag_children(@article,params[:tag_children_ids],params[:tag_children_descriptions])
      redirect_to website_articles_path(article_type: @article.as_article? ? 'as_article' : 'as_product'), notice: "保存成功"
    else
      render_with_alert :form, "保存失败，#{@article.errors.full_messages.join(', ')}"
    end
	end

	def update
    @article.taggings.destroy_all
    if @article.update_attributes(params[:website_article])
    	save_article_tag_children(@article,params[:tag_children_ids],params[:tag_children_descriptions])
      redirect_to website_articles_path(article_type: @article.as_article? ? 'as_article' : 'as_product'), notice: "保存成功"
    else
      render_with_alert :form, "保存失败，#{@article.errors.full_messages.join(', ')}"
    end
	end

	def destroy
		@article.delete
    redirect_to :back, notice: "操作成功"
  end
  
  def change_status
    ids = params[:ids].split(",")
    @website.website_articles.where(id: ids).update_all(status: params[:status])
    render json: {result: 'success', ids: ids}  
  end

  def copy_article
    ids = params[:ids].split(",")
    @website.website_articles.where(id: ids).each do |article|
      index = article.copys.collect(&:title).map{|f| f.split("#{article.title}副本").last }.compact.max.to_i + 1
      attrs = article.attributes.merge!(title: "#{article.title}副本#{index}", copy_id: article.id)
      attrs.delete("id")
      new_article = WebsiteArticle.new(attrs)
      new_article.content = article.content
      article.taggings.each{|f| new_article.taggings << Tagging.new(tag_id: f.tag_id, description: f.description)}
      new_article.save
    end
    #render js: "showTip('notice', '复制成功');"
    redirect_to :back, notice: '复制成功'
  end

  def delete_articles
    ids = params[:ids].split(",")
    @website.website_articles.where(id: ids).destroy_all
    redirect_to :back, notice: '操作成功'
  end

	def select_categorie
		total_categories = @website.website_article_categories.send(params[:category_type])
		if params[:parent_id].present?
			categories = total_categories.where(parent_id: params[:parent_id]).collect do |c|
				{name: c.name, value: c.id}
			end
		end
		if params[:tag] == "1" && params[:parent_id].present?
			if params[:category_type] == "as_article"
				tags = total_categories.where(id: params[:parent_id]).first.tags.collect do |c|
					{name: c.name, value: c.id}
				end
			else
				tags = total_categories.where(id: params[:parent_id]).first.tags.tag_root.collect do |c|
					{name: c.name, inpval: c.id, ops: get_ops(c)}
				end
			end
			return render json: {result: 'success', categories: [{select: get_categorie_tags(categories), tags: tags}]}
		end
    return render json: {result: 'success', categories: [{select: [], tags: []}]} if params[:tag] == "1" && params[:parent_id].blank?
		render json: {result: 'success', categories: get_categorie_tags(categories)}
	end

	def edit_pic
		render layout: 'application_pop'
	end

	def update_pic
		if @article.update_attributes(params[:website_article])
			flash[:notice] = "操作成功"
      render inline: "<script>window.parent.document.getElementById('weisiteModal').style.display='none';window.parent.location.reload();</script>"
    else
    	render_with_alert :edit_pic, '操作失败', layout: 'application_pop'
  	end
	end

	def delete_pic
		@article.update_attributes(pic: nil)
		render json: {result: 'success'}
	end

	def update_sort
		@article.update_attributes(sort: params[:sort])
		render js: "showTip('notice', '修改成功');"
	end

  def change_is_top
    if @article.update_attributes(is_top: params[:is_top]) 
      render json: {result: 'success', id: @article.id}  
    else
      render json: {result: 'failure', err_msg: @article.errors.full_messages.join(',')} 
    end
  end

  private


  def set_website
    @website = current_user.website
    return redirect_to websites_path, alert: '请先设置微官网' unless @website
  end

  def find_article
    @article = @website.website_articles.find params[:id]
  end

  def get_ops(root_tag)
  	children_tags = root_tag.children.collect do |c|
			{value: c.id, name: c.name, description: ""}
		end
		return children_tags
  end

  def save_article_tag_children(article,children_ids,descriptions=[])
  	if children_ids.present?
	  	children_ids.each_with_index do |tag_id,i|
		  	@article.taggings.create(tag_id: tag_id, description: descriptions[i])
		  end
		end
  end

  def get_categorie_tags(categories)
  	return categories.blank? ? [] : categories.insert(0,{name: "", value: ""})
  end
end
