class Huodong::ShakeSitesController < ApplicationController
  layout 'shake_site'

  helper_method :broadcast, :shake_site

  skip_before_filter *ADMIN_FILTERS

  before_filter :require_shake_site, except: [:index]
  before_filter :find_shake, only: [:get_user_count, :update_user, :shake_start, :shake_end]

  def index
    session[:shake_account_id] = Des.decrypt(params[:account_id], validate_time: false)
    session[:shake_id] = params[:id]
    @shake = shake_site.shakes.where(id: session[:shake_id]).first
  rescue
    return render_404
  end

  #更新活动页面参与者人数
  def get_user_count
    user_count = @shake.shake_users.shake_at.normal_user.count
    user_count = user_count.to_s.split('').map{|i| "<i>#{i}</i>" }.join
    render text: user_count
  end

  #更新活动页面参与者列表
  def update_user
    shake_round = @shake.shake_rounds.last
    user_num = DbRedis.top_shake_round_users(shake_site.id, shake_round.id, 8)
    shake_users = @shake.shake_users.where(id: user_num).order("find_in_set(id, '#{user_num.join(",")}')").pluck(:id,:avatar,:nickname)
    shake_users.map!{|u| 
      shake_count = DbRedis.get_user_shake_count(shake_site.id, shake_round.id, u[0])
      u << if shake_count == 0
        ''
      elsif shake_count >= @shake.mode_value
        '100'
      else
        tmp = shake_count / @shake.mode_value.to_f * 100
        tmp < 9 ? 9 : tmp.to_s
      end
    }
    render json: {user: shake_users}
  end

  #活动开始
  def shake_start
    shake_round = @shake.shake_rounds.last
    shake_round.update_attributes!(status: ShakeRound::STOPPED) if shake_round
    new_shake_round = @shake.shake_rounds.create(site_id: shake_site.id, activity_id: @shake.activity.id, shake_round: (shake_round.try(:shake_round).to_i + 1), status: ShakeRound::ACTIVE)
    broadcast("/mobile/shake_start/#{session[:shake_id]}",{shake_round_id: new_shake_round.id})
    countdown = new_shake_round.shake_round.to_s.split('').map{|i| "<i>#{i}</i>" }.join
    render text: countdown
  end

  #活动结束
  def shake_end
    broadcast("/mobile/shake_end/#{session[:shake_id]}")
    shake_round = @shake.shake_rounds.last
    shake_user_num = @shake.shake_users.shake_at.count
    # DbRedis.get_shake_round_user_num(shake_site.id, shake_round.id)

    shake_round.update_attributes!(status: ShakeRound::STOPPED, shake_user_num: shake_user_num)
    user_ranks = DbRedis.top_shake_round_users(shake_site.id, shake_round.id, shake_round.shake.prize_user_num, with_scores: 1)
    users = user_ranks.map.with_index do |(shake_user_id, shake_count), index|
      shake_user = shake_site.shake_users.where(id: user_ranks.map(&:first)).find{ |user| user.id == shake_user_id.to_i }
      shake_round.first_or_create_shake_prize(shake_user, index + 1) rescue nil
      {id: shake_user_id, nickname: shake_user.nickname, avatar: shake_user.avatar, count: shake_count.to_i}
    end
    render json: users
  end

  private

    def broadcast(channel, data = nil)
      message = {channel: channel, data: data}
      uri = URI.parse("http://#{FAYE_HOST}/faye")
      Net::HTTP.post_form(uri, message: message.to_json)
    end

    def require_shake_site
      redirect_to shakes_path, alert: '操作失败' unless session[:shake_account_id]
    end

    def shake_site
      @shake_site ||= Account.where(id: session[:shake_account_id]).first.site
    end

    def find_shake
      @shake = shake_site.shakes.where(id: params[:id]).first
      redirect_to shakes_path, alert: '您访问的页面不存在' unless @shake
    end
end
