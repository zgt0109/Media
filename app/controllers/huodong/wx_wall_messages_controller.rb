class Huodong::WxWallMessagesController < ApplicationController

  before_filter :get_wall
  before_filter :find_wx_wall_message, only: [ :destroy, :pull_black, :allow ]

  def index
    @type = params[:type].presence || "normal"
    status = WxWallMessage.const_get(@type.upcase) rescue WxWallMessage::NORMAL
    @search = @wx_wall.wx_wall_messages.where(status: status).recent.search(params[:search])
    @wx_wall_messages = @search.page(params[:page])
  end

  def destroy
    if @wx_wall_message.deleted!
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, notice: '操作失败'
    end
  end

  def pull_black
    @wx_wall_user = @wx_wall_message.wx_wall_user
    @wx_wall_user.blacklist!
    @wx_wall_user.wx_wall_messages.update_all(status: WxWallMessage::BLACKLIST)
    redirect_to :back, notice: '操作成功'
  end

  def allow
    if @wx_wall_message.normal!
      @wx_wall_message.wx_wall_user.normal!
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, notice: '操作失败'
    end
  end

  private

    def get_wall
      session[:wx_wall_id] = params[:wx_wall_id] if params[:wx_wall_id]
      session[:wx_wall_id] = params[:search][:wx_wall_id_eq] if params[:search]
      @wx_wall = current_user.wx_walls.where(id: session[:wx_wall_id]).first || current_user.wx_walls.show.first
      return redirect_to wx_walls_path, alert: '请先添加微信墙活动' unless @wx_wall
      session[:wx_wall_id] = @wx_wall.id
    end

    def find_wx_wall_message
      @wx_wall_message = @wx_wall.wx_wall_messages.find(params[:id])
    end

end
