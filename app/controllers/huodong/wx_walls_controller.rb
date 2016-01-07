class Huodong::WxWallsController < ApplicationController
  include ApplicationHelper
  helper_method :message_html
  Refresh_Time = 5000
  
  before_filter :find_wx_wall, except: [ :index, :new, :create, :help, :save_qiniu_keys, :destroy_qiniu_keys, :preview_template ]

  def index
    wx_walls = current_user.wx_walls.show.order('id DESC')
    if params[:search].present? && params[:search][:activity_status_eq].present?
      @activity_status = params[:search][:activity_status_eq]
      params[:search].delete(:activity_status_eq)
      wall_ids = current_user.activities.wx_wall.select do |act|
        act.activity_status == @activity_status.to_i
      end.map(&:activityable_id)
      @search = wx_walls.where(id: wall_ids).search(params[:search])
    else
      @search = wx_walls.search(params[:search])
    end
    @wx_walls = @search.page(params[:page])
    
  end

  def new
    @wx_wall = current_user.wx_walls.new(activity: Activity.new, template_id: 1, system_template: true)
    render :form
  end

  def edit
    render :form
  end

  def help
    render layout: 'application_gm'
  end

  def create
    @wx_wall = current_user.wx_walls.new(params[:wx_wall])
    if @wx_wall.save
      redirect_to extra_settings_wx_wall_path(@wx_wall, notice: "保存成功")
    else
      render_with_alert :form, "保存失败，#{@wx_wall.errors.full_messages.first}"
    end
  end

  def update
    wx_wall_prizes_attributes = params[:wx_wall].delete(:wx_wall_prizes_attributes) if params[:wx_wall] && params[:wx_wall][:wx_wall_prizes_attributes].present?
    wx_wall_winning_users_attributes = params[:wx_wall].delete(:wx_wall_winning_users_attributes) if params[:wx_wall] && params[:wx_wall][:wx_wall_winning_users_attributes].present?

    if @wx_wall.update_attributes(params[:wx_wall])
      if wx_wall_prizes_attributes.present?
        @wx_wall.wx_wall_prizes.delete_all
        wx_wall_prizes_attributes.each  do |key, params|
          @wx_wall.wx_wall_prizes.create(params)
        end
      end

      params[:added_keys].to_s.split(',').each do |sn|
        @wx_wall.qiniu_pictures.where(sn: sn).first_or_create if sn.present?
      end

      params[:removed_keys].to_s.split(',').each do |sn|
        image = @wx_wall.qiniu_pictures.where(sn: sn).first
        image.delete if image
      end

      if wx_wall_winning_users_attributes.present?
        @wx_wall.wx_wall_winning_users.delete_all
        wx_wall_winning_users_attributes.each  do |key, params|
          if params[:vip_user_id].present?
            vip_user = current_user.wx_mp_user.vip_users.visible.where(user_no: params[:vip_user_id]).first
            return render js: 'showTip("warning", "保存失败,会员不存在");' unless vip_user
            @wx_wall.wx_wall_winning_users.create(params.merge!(vip_user_id: vip_user.id, wx_user_id: vip_user.wx_user_id))
          end
        end
      end

      respond_to do |format|
        format.js {render js: 'showTip("success", "保存成功"); $(".submit-settings").attr("disabled", false)'}
        format.html { redirect_to :back, notice: "保存成功" }
      end
    else
      respond_to do |format|
        format.js {render js: "showTip('warning', '保存失败，#{@wx_wall.errors.full_messages.first}'); $('.submit-settings').attr('disabled', false)" }
        format.html { render_with_alert :form, "保存失败，#{@wx_wall.errors.full_messages.first}" }
      end
      
    end
  end

  def destroy
    @wx_wall.mark_delete!
    redirect_to :back, notice: "操作成功"
  end

  def stop
    @wx_wall.mark_stop!
    redirect_to :back, notice: "操作成功"
  end

  def start
    @wx_wall.mark_start!
    redirect_to :back, notice: "操作成功"
  end

  def extra_settings
    @pictures = @wx_wall.qiniu_pictures.order("id desc")
    @qiniu_token = Qiniu.generate_upload_token scope: BUCKET_PICTURES
    # render layout: 'application_pop'
  end

  def add_new_prize
    render partial: "prize_form_area", locals: {index: params[:index].to_i, lottery_type: params[:lottery_type]}
  end

  def destroy_qiniu_keys
    qiniu_picture_id = params[:qiniu_picture_id]
    qiniu_picture = QiniuPicture.find_by_id(qiniu_picture_id)
    qiniu_picture.destroy
    render json: {}
  end

  def save_qiniu_keys
    # "name"=>"QQ图片20140314185318.jpg"
    wx_wall_id = params[:wx_wall_id].to_i
    if wx_wall_id > 0
      pic = QiniuPicture.create(target_id: wx_wall_id, target_type: 'WxWall', sn: params[:qiniu_pic_key])
    end
    render partial: "photo_li", locals: {photo: (pic || QiniuPicture.new)}
  end

  def show
    return render inline: "<script>alert('活动不存在');</script>" if @wx_wall.deleted?
    @wx_wall_messages = @wx_wall.wx_wall_messages.normal.includes(:wx_wall_user).limit(10)
    @pictures         = @wx_wall.qiniu_pictures.to_a
    @wx_wall_prizes   = @wx_wall.wx_wall_prizes.normal.to_a
    @wx_wall_users    = @wx_wall.wx_wall_users.normal.full.recent.to_a
    @vote_items       = @wx_wall.vote.activity_vote_items.sort { |item1, item2| item2.per <=> item1.per } rescue []
    @wx_wall_prizes_wx_wall_users = @wx_wall.wx_wall_prizes_wx_wall_users.free_mode_users.order("created_at DESC")

    render layout: false
  end

  def lottery
    if @wx_wall.free_mode?
      temp,user_url,user_name,user_html = @wx_wall.draw_user!
      render json:{temp: temp, user_url: user_url, user_name: user_name, user_html: user_html}
    else
      prize_hash = @wx_wall.draw_prize!
      wuser = @wx_wall.wx_wall_users.where(id: prize_hash[:user_id]).first
      users = @wx_wall.wx_wall_users.normal.where("id != #{prize_hash[:user_id]}")
      html = WxWallUser.win_user(wuser,users)
      render json:{prize_id: prize_hash[:prize_id], user_id: prize_hash[:user_id], html: html}
    end
  end

  def winner_list
    @user_prizes = @wx_wall.wx_wall_prizes_wx_wall_users.random_mode_users.joins(:wx_wall_prize).order("wx_wall_prizes.id ASC, wx_wall_prizes_wx_wall_users.id ASC")
  end

  def messages
    @messages = @wx_wall.wx_wall_messages.normal
    @messages = @messages.where("id > ?", params[:message_id]) if params[:message_id].to_i > 0
  end

  def get_message
    if params[:type] == "J-mark-3"
      #更新抽奖者
      wx_wall_users = @wx_wall.wx_wall_users.normal.full
      @wx_wall_users = wx_wall_users.recent.where("id > ?", params[:user_id]) unless @wx_wall.free_mode?
      @user_count = wx_wall_users.count
    elsif params[:type] == "J-mark-4"
      #更新投票
      @num = @wx_wall.vote.activity_user_vote_items.count('distinct(wx_user_id)') rescue 0
      @vote_items = @wx_wall.vote.activity_vote_items.sort { |item1, item2| item2.per <=> item1.per } rescue []
    elsif params[:type] == "J-mark-0"
      #更新签到
      signin_user_ids = params[:signin_user_ids].to_s.split(",")
      wx_wall_user = @wx_wall.wx_wall_users.normal.full.signin_users(signin_user_ids).recent.first
      @avatar = wx_wall_user.try(:avatar_url)
      signin_user_ids << wx_wall_user.id if wx_wall_user
      @user_ids = signin_user_ids.join(",")
    else
      #更新留言
      if params[:num].to_i > 0
        @wx_wall_messages = @wx_wall.replace_message(params)
        @html = message_html(@wx_wall_messages)
      end
    end
  end

  def delete_prize_user
    if params[:delete_all] == "1"
      users = @wx_wall.wx_wall_prizes_wx_wall_users.free_mode_users
      render json: {status: users.try(:delete_all) ? true : false}
    else
      user = @wx_wall.wx_wall_prizes_wx_wall_users.free_mode_users.where(id: params[:wx_wall_user_id]).first
      render json: {status: user.try(:delete) ? true : false}
    end
  end

  def preview_template
    render layout: 'application_pop'
  end

  private
    def find_wx_wall
      @wx_wall = current_user.wx_walls.find(params[:id])
    end

    def message_html(messages)
      html = ""
      messages.to_a.each do |m|
        img = m.wx_wall_user.try(:avatar_url).presence || "/assets/wx_wall/user-img.jpg"
        message = m.text? ? m.message : "<img src='#{m.pic}'/>"
        html << "<li data-id='#{m.id}'><div class='user-left'><div class='user-img'><img src='#{img}'/></div></div>"
        html << "<div class='user-msg'><h1>#{m.wx_wall_user.try(:nickname)}</h1><div class='msg-box msg-#{m.message_css}'>#{message}</div></div></li>"
      end
      return html
    end

end
