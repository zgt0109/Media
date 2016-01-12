class Wx::MenusController < ApplicationController
  before_filter :require_wx_mp_user
  before_filter :find_wx_menu, only: [:show, :edit, :update, :destroy, :edit_wx_menu]

  before_filter do
    @partialLeftNav = "/layouts/partialLeftWeixin"
  end

  def index
    @wx_menus = @wx_mp_user.wx_menus
  end

  def new
    @wx_menu = @wx_mp_user.wx_menus.new(parent_id: params[:parent_id].to_i, event_type: "click", menu_type: "1", content: "默认文本")

    return render :text=> "至多只能添加3个一级菜单" if @wx_menu.parent? && @wx_mp_user.wx_menus.root.count >= 3
    return render :text=> "至多只能添加5个二级子菜单" if @wx_menu.child? && @wx_menu.parent.children.count >= 5

    @wx_menu.key = [@wx_mp_user.id, (@wx_mp_user.wx_menus.order(:id).last.try(:id) || 0)+1].join('_')
    @wx_menu.sort = params[:parent_id].present? ? @wx_menu.parent.children.count + 1 : @wx_mp_user.wx_menus.root.count + 1
    render :partial=> "form"
  end

  def create
    @wx_menu = @wx_mp_user.wx_menus.new(params[:wx_menu])

    respond_to do |format|
      if @wx_menu.save
        format.html { redirect_to wx_menus_url, notice: '添加成功' }
        format.json { render action: 'show', status: :created, location: @wx_menu }
      else
        format.html { redirect_to :back, alert: "添加失败:#{@wx_menu.errors.full_messages.first}" }
        format.json { render json: @wx_menu.errors, status: :unprocessable_entity }
      end
    end
  rescue => error
    redirect_to :back, alert: "添加失败:#{error}"
  end

  def update
    respond_to do |format|
      if @wx_menu.update_attributes(params[:wx_menu])
        format.html { redirect_to wx_menus_url, notice: '保存成功' }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, alert: "保存失败:#{@wx_menu.errors.full_messages.join}" }
        format.json { render json: @wx_menu.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @wx_menu.destroy
    respond_to do |format|
      format.html { redirect_to wx_menus_url }
      format.json { head :no_content }
    end
  end

  def up_menu
    first_wx_menu = @wx_mp_user.wx_menus.where(parent_id: params[:parent_id], id: params[:id]).first
    second_wx_menu = @wx_mp_user.wx_menus.where(parent_id: params[:parent_id], sort: (first_wx_menu.sort-1)).first if first_wx_menu
    if first_wx_menu.blank? || second_wx_menu.blank?
      WxMenu.new_sort(@wx_mp_user.wx_menus.where(parent_id: params[:parent_id]))
    else
      first_wx_menu.minus_sort
      second_wx_menu.add_sort
    end
    render text: nil 
  end

  def down_menu
    first_wx_menu = @wx_mp_user.wx_menus.where(parent_id: params[:parent_id], id: params[:id]).first
    second_wx_menu = @wx_mp_user.wx_menus.where(parent_id: params[:parent_id], sort: (first_wx_menu.sort+1)).first if first_wx_menu
    if first_wx_menu.blank? || second_wx_menu.blank?
      WxMenu.new_sort(@wx_mp_user.wx_menus.where(parent_id: params[:parent_id]))
    else
      first_wx_menu.add_sort
      second_wx_menu.minus_sort
    end
    render text: nil
  end

  private
    def find_wx_menu
      @wx_menu = @wx_mp_user.wx_menus.where(id: params[:id]).first
      return redirect_to wx_menus_url, alert: '不存在' unless @wx_menu
    end

end
