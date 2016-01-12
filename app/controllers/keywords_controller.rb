class KeywordsController < ApplicationController

  before_filter :load_keyword, only: [:show, :edit, :update, :destroy]

  before_filter do
    @partialLeftNav = "/layouts/partialLeftWeixin"
  end

  def index
    @search = current_site.keywords.order('created_at DESC').search(params[:search])
    @keywords = @search.page(params[:page])
  end

  def new
    @keyword = current_site.keywords.new
    render layout: 'application_pop'
  end

  def create
    @keyword = current_site.keywords.new(params[:keyword])
    if @keyword.save
      flash[:notice] = '添加成功'
      render inline: "<script>window.parent.location.href = '#{keywords_path}';</script>"
    else
      flash[:alert] = "添加失败"
      render action: 'new', layout: 'application_pop'
    end
  end

  def edit
    render layout: 'application_pop'
  end

  def update
    if @keyword.update_attributes(params[:keyword])
      flash[:notice] = '保存成功'
      render inline: "<script>window.parent.location.href = '#{keywords_path}';</script>"
    else
      flash[:alert] = "保存失败"
      render action: 'edit', layout: 'application_pop'
    end
  end

  def destroy
    @keyword.destroy
    respond_to do |format|
      format.html { redirect_to keywords_path, notice: '删除成功' }
      format.json { head :no_content }
    end
  end

  def destroy_multi
    if params[:ids].present?
      current_site.keywords.where(id: params[:ids]).delete_all
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, notice: '请先选中需要删除的关键词'
    end
  end

  private
    def load_keyword
      @keyword = current_site.keywords.find(params[:id])
    end

end
