class WebsiteShared::WebsitesController < WebsiteShared::WebsiteBaseController

  def index
  end

  def update
    respond_to do |format|
      if @website.update_attributes(params[:website])
        format.html { redirect_to :back, notice: '保存成功' }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, notice: '保存失败' }
        format.json { render json: @website.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @website.clear_menus!
      redirect_to :back
    else
      redirect_to :back, notice: '操作失败'
    end
  end
  
  def open_popup_menu
    if @website.open_popup_menu!
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, notice: '操作失败'
    end
  end
  
  def close_popup_menu
    if @website.close_popup_menu!
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, notice: '操作失败'
    end
  end
  
  def toggle_popup
    respond_to do |format|
      @website.update_attributes(is_open_life_popup: !@website.is_open_life_popup)
      format.html { redirect_to :back, notice: '操作成功' }
      format.js { render js: 'showTip("success", "操作成功");' }
    end
  end

end
