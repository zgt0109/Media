class WxWall < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :material
  has_one :activity, as: :activityable, conditions: { activity_type_id: ActivityType::WX_WALL }
  has_many :wx_wall_prizes_wx_wall_users, dependent: :destroy
  has_many :wx_wall_prizes, dependent: :destroy
  has_many :wx_wall_users
  has_many :wx_wall_messages
  has_many :qiniu_pictures, as: :target
  has_many :wx_wall_winning_users, dependent: :destroy

  scope :show, -> { where( "wx_walls.status > ?", DELETED ) }

  accepts_nested_attributes_for :activity, :wx_wall_prizes, :wx_wall_winning_users

  store :metadata, accessors: [:vote_id, :lottery_type, :signin_check, :picture_check, :prize_check, :vote_check, :shake_check, :enroll_check, :shake_id, :enroll_id]

  enum_attr :status, :in => [
    ['setted',    1, '已配置'],
    ['stopped', -1, '已停止'],
    ['deleted', -2, '已删除']
  ]

  enum_attr :lottery_type, :in => [
    ['free_mode',   '1', '自由控制模式'],
    ['random_mode', '2', '系统随机模式']
  ]

  %i(name keyword start_at end_at starting?).each do |method_name|
    delegate method_name, to: :activity, allow_nil: true
  end

  def custom_template_url
    qiniu_image_url(custom_template)
  end

  def system_template_url
    template_id.present? ? "/assets/wx_wall/template/v#{template_id}.png" : '/assets/wx_wall/template/v1.png'
  end

  def template_url
    system_template? ? system_template_url : custom_template_url
  end

  def logo_url
    logo.present? ? qiniu_image_url(logo) : '/assets/bg_fm.jpg'
  end

  def qrcode_url
    qrcode.present? ? qiniu_image_url(qrcode) : '/assets/bg_fm.jpg'
  end

  def vote
    @vote ||= supplier.activities.where(id: vote_id).first if vote_id.present?
  end

  def shake
    @shake ||= supplier.activities.where(id: shake_id).first if shake_id.present?
  end

  def enroll
    @enroll ||= supplier.activities.where(id: enroll_id).first if enroll_id.present?
  end

  def activity_status_name
    activity.try(:activity_status_name) || status_name
  end

  def mark_delete!
    activity.update_column(:status, Activity::DELETED) if activity
    update_column(:status, DELETED)
  end

  def mark_stop!
    activity.update_column(:status, Activity::STOPPED) if activity
    update_column(:status, STOPPED)
  end

  def mark_start!
    activity.update_column(:status, Activity::SETTED) if activity
    update_column(:status, SETTED)
  end

  def draw_prize!
    user_id, prize_id = draw_user_id, draw_prize_id
    draw_prize_for_user(user_id, prize_id) if prize_id.to_i > 0 && user_id.to_i > 0
    { user_id: user_id, prize_id: prize_id }
  end

  def not_started?
    !pre_join? && !activity.starting?
  end

  def replace_message(params)
    case params[:direction]
    when "start" then wx_wall_messages.normal.includes(:wx_wall_user).limit(params[:num].to_i*2) if wx_wall_messages.normal.first.try(:id) != params[:last_id].to_i
    when "top" then wx_wall_messages.normal.where("id < ?", params[:last_id].to_i).includes(:wx_wall_user).last(params[:num].to_i)
    when "end" then wx_wall_messages.normal.includes(:wx_wall_user).last(params[:num].to_i*2) if wx_wall_messages.normal.last.try(:id) != params[:last_id].to_i
    else
      wx_wall_messages.normal.where("id > ?", params[:last_id].to_i).includes(:wx_wall_user).limit(params[:num].to_i)
    end
  end

  def draw_user!
    users = wx_wall_users.normal.full
    return ["","","",""] if users.count == 0
    temp = arr_user_temp(users)
    users = users.where("NOT EXISTS(select 1 from wx_wall_prizes_wx_wall_users where wx_wall_prizes_wx_wall_users.wx_wall_prize_id is null and wx_wall_users.id = wx_wall_prizes_wx_wall_users.wx_wall_user_id)")
    win_wx_user_id = wx_wall_winning_users.normal.first.try(:wx_user_id)
    if users.pluck(:wx_user_id).include?(win_wx_user_id)
      user = wx_wall_users.where(wx_user_id: win_wx_user_id).first
    else
      user = WxWallUser.where(id: users.pluck(:id).sample).first
    end
    wx_wall_prizes_wx_wall_users.create(wx_wall_user: user, nickname: user.nickname, avatar: user.avatar) if user
    [temp, user.try(:avatar).to_s, user.try(:nickname).to_s, user_html(user)]
  end

  def arr_user_temp(users)
    temp = []
    users.order("created_at DESC").limit(10).each do |user|
      temp << {url: user.avatar, name: user.nickname}
    end
    return temp
  end

  def user_html(user)
    html = ""
    if user
      id = user.wx_wall_prizes_wx_wall_users.where("wx_wall_prize_id is null").first.try(:id)
      html << "<li class='hide'><div class='list-num'></div><div class='list-img'>"
      html << "<img src='#{user.avatar}'></div><div class='list-name'>#{user.nickname}</div>"
      html << "<div class='list-del' data-id='#{id}'>X</div></li>"
    end
    return html
  end

  def extra_check_box_names
    {
      signin_check: "签到墙",
      prize_check: "抽奖",
      picture_check: "现场图片",
      vote_check: "微投票",
      shake_check: "摇一摇",
      enroll_check: "微报名"
    }
  end

  def wx_shake_id
    Activity.where(id: shake_id).first.try(:activityable_id)
  end

  private
    def draw_prize_id
      prize_ids_with_num = Hash[ wx_wall_prizes.normal.pluck(:id, :num) ]
      wx_wall_prizes_wx_wall_users.select("wx_wall_prize_id, count(*) count").group("wx_wall_prize_id").each do |prize|
        prize_ids_with_num[ prize.wx_wall_prize_id ] = [ prize_ids_with_num[ prize.wx_wall_prize_id ].to_i - prize.count, 0 ].max
      end
      prize_ids_with_num.map { |id, num| [ id ] * num }.flatten.sample
    end

    def draw_user_id
      users = wx_wall_users.normal.full
      return 0 if users.count == 0
      users = users.where("NOT EXISTS(select 1 from wx_wall_prizes_wx_wall_users where wx_wall_prizes_wx_wall_users.wx_wall_prize_id is not null and wx_wall_users.id = wx_wall_prizes_wx_wall_users.wx_wall_user_id)") unless repeat_draw?
      users.pluck(:id).sample
    end

    def draw_prize_for_user(user_id, prize_id)
      user  = WxWallUser.find  user_id
      prize = WxWallPrize.find prize_id
      wx_wall_prizes_wx_wall_users.create! wx_wall_prize: prize, wx_wall_user: user, prize_grade: prize.grade, prize_name: prize.name, prize_pic: prize.pic_key, nickname: user.nickname, avatar: user.avatar
    end

end