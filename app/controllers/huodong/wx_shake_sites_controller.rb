class Huodong::WxShakeSitesController < ApplicationController
  layout 'shake_site'
  helper_method :broadcast, :shake_supplier
  skip_before_filter *ADMIN_FILTERS
  before_filter :require_shake_supplier, except: [:index]
  before_filter :find_wx_shake, only: [:get_user_count, :update_user, :shake_start, :shake_end]

  def index
    session[:shake_supplier_id] = Des.decrypt(params[:supplier_id], validate_time: false)
    session[:wx_shake_id] = params[:id]
    @wx_shake = shake_supplier.wx_shakes.where(id: session[:wx_shake_id]).first
  rescue
    return render_404
  end

  #更新活动页面参与者人数
  def get_user_count
    user_count = @wx_shake.wx_shake_users.wx_shake_at.normal_user.count
    user_count = user_count.to_s.split('').map{|i| "<i>#{i}</i>" }.join
    render text: user_count
  end

  #更新活动页面参与者列表
  def update_user
    wx_shake_round = @wx_shake.wx_shake_rounds.last
    user_num = DbRedis.top_shake_round_users(shake_supplier.id, wx_shake_round.id, 8)
    wx_shake_users = @wx_shake.wx_shake_users.where(id: user_num).order("find_in_set(id, '#{user_num.join(",")}')").pluck(:id,:avatar,:nickname)
    wx_shake_users.map!{|u| 
      shake_count = DbRedis.get_user_shake_count(shake_supplier.id, wx_shake_round.id, u[0])
      u << if shake_count == 0
        ''
      elsif shake_count >= @wx_shake.mode_value
        '100'
      else
        tmp = shake_count / @wx_shake.mode_value.to_f * 100
        tmp < 9 ? 9 : tmp.to_s
      end
    }
    render json: {user: wx_shake_users}
  end

  #活动开始
  def shake_start
    wx_shake_round = @wx_shake.wx_shake_rounds.last
    wx_shake_round.update_attributes!(status: WxShakeRound::STOPPED) if wx_shake_round
    new_shake_round = @wx_shake.wx_shake_rounds.create(supplier_id: shake_supplier.id, activity_id: @wx_shake.activity.id, shake_round: (wx_shake_round.try(:shake_round).to_i + 1), status: WxShakeRound::ACTIVE)
    broadcast("/mobile/wx_shake_start/#{session[:wx_shake_id]}",{shake_round_id: new_shake_round.id})
    countdown = new_shake_round.shake_round.to_s.split('').map{|i| "<i>#{i}</i>" }.join
    render text: countdown
  end

  #活动结束
  def shake_end
    broadcast("/mobile/wx_shake_end/#{session[:wx_shake_id]}")
    wx_shake_round = @wx_shake.wx_shake_rounds.last
    shake_user_num = @wx_shake.wx_shake_users.wx_shake_at.count
    # DbRedis.get_shake_round_user_num(shake_supplier.id, wx_shake_round.id)

    wx_shake_round.update_attributes!(status: WxShakeRound::STOPPED, shake_user_num: shake_user_num)
    user_ranks = DbRedis.top_shake_round_users(shake_supplier.id, wx_shake_round.id, wx_shake_round.wx_shake.prize_user_num, with_scores: 1)
    users = user_ranks.map.with_index do |(shake_user_id, shake_count), index|
      wx_shake_user = shake_supplier.wx_shake_users.where(id: user_ranks.map(&:first)).find{ |user| user.id == shake_user_id.to_i }
      wx_shake_round.first_or_create_wx_shake_prize(wx_shake_user, index + 1) rescue nil
      {id: shake_user_id, nickname: wx_shake_user.nickname, avatar: wx_shake_user.avatar, count: shake_count.to_i}
    end
    render json: users
  end

  private

    def broadcast(channel, data = nil)
      message = {channel: channel, data: data}
      uri = URI.parse("http://#{FAYE_HOST}/faye")
      Net::HTTP.post_form(uri, message: message.to_json)
    end

    def require_shake_supplier
      redirect_to wx_shakes_path, alert: '操作失败' unless session[:shake_supplier_id]
    end

    def shake_supplier
      @shake_supplier ||= Supplier.where(id: session[:shake_supplier_id]).first
    end

    def find_wx_shake
      @wx_shake = shake_supplier.wx_shakes.where(id: params[:id]).first
      redirect_to wx_shakes_path, alert: '您访问的页面不存在' unless @wx_shake
    end
end
