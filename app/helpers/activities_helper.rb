module ActivitiesHelper
  MARKETING_ACTIVITY_IDS = [
    ActivityType::GUA,
    ActivityType::WHEEL,
    ActivityType::FIGHT,
    ActivityType::HIT_EGG,
    ActivityType::SLOT,
    ActivityType::COUPON,
    ActivityType::GUESS,
    ActivityType::MICRO_AID
  ]
  BIZ_ACTIVITY_IDS = [
    ActivityType::VOTE,
    ActivityType::GROUPS,
    ActivityType::SURVEYS,
    ActivityType::MESSAGE,
    ActivityType::WBBS_COMMUNITY,
    ActivityType::DONATION,
    ActivityType::GUESS
  ]

  MARKETING_SITE_IDS = [
    ActivityType::WX_WALL,
    ActivityType::SHAKE
  ]

  def activity_notes(activity_type_id)
    if activity_type_id == ActivityType::SURVEYS
      "<li>1、活动开始后，为确保调研数据的准确性，最好不要修改已设置的题目内容；</li><li>2、未限制调研时间的活动需要手动“开启”后调研活动才能开始；</li>"
    elsif activity_type_id == ActivityType::VOTE
      "<li>1、未限制投票时间的活动需要手动“开启”后活动才能开始；</li>"
    end.html_safe
  end

  def activities_path_by_type(activity_type_id)
    case activity_type_id.to_i
    when ActivityType::GUA       then guas_activities_path
    when ActivityType::WHEEL     then wheels_activities_path
    when ActivityType::FIGHT     then fights_activities_path
    when ActivityType::VOTE      then votes_activities_path
    when ActivityType::GROUPS    then groups_activities_path
    when ActivityType::SURVEYS   then surveys_activities_path
    when ActivityType::HIT_EGG   then hit_eggs_activities_path
    when ActivityType::SLOT      then slots_activities_path
    when ActivityType::COUPON    then coupons_path
    when ActivityType::RECOMMEND then recommends_activities_path
    when ActivityType::UNFOLD    then unfolds_activities_path
    when ActivityType::SCENE     then scenes_path
    when ActivityType::GUESS     then guesses_activities_path
    end
  end

  def link_to_activities_by_type(activity_type_id, options = {})
    case activity_type_id.to_i
    when ActivityType::GUA       then link_to('刮刮卡', guas_activities_path,     options)
    when ActivityType::WHEEL     then link_to('大转盘', wheels_activities_path,   options)
    when ActivityType::FIGHT     then link_to('一战到底',  fights_activities_path,   options)
    when ActivityType::VOTE      then link_to('我的投票',  votes_activities_path,    options)
    when ActivityType::GROUPS    then link_to('我的团购',  groups_activities_path,   options)
    when ActivityType::SURVEYS   then link_to('我的调研',  surveys_activities_path,  options)
    when ActivityType::HIT_EGG   then link_to('砸金蛋',    hit_eggs_activities_path, options)
    when ActivityType::SLOT      then link_to('老虎机',    slots_activities_path,     options)
    when ActivityType::COUPON    then link_to('新电子优惠券',    coupons_path,     options)
    when ActivityType::WAVE      then link_to('摇一摇抽奖',    waves_activities_path,     options)
    when ActivityType::RECOMMEND then link_to('推荐有奖',    recommends_activities_path,     options)
    when ActivityType::UNFOLD    then link_to('拆包有奖',    unfolds_activities_path,     options)
    when ActivityType::SCENE     then link_to('微场景',    scenes_path,     options)
    when ActivityType::GUESS     then link_to('美图猜猜',    guesses_activities_path,     options)
    when ActivityType::MICRO_AID then link_to('微助力',      aids_activities_path, options)
    else
      link_to('我的营销活动', activities_path, options)
    end
  end

  def link_to_activities_reports_by_type(activity_type_id, options = {})
    name = {
      ActivityType::GUA     => '刮刮卡报表',
      ActivityType::WHEEL   => '大转盘报表',
      ActivityType::HIT_EGG => '砸金蛋报表',
      ActivityType::SLOT    => '老虎机报表',
      ActivityType::FIGHT   => '一战到底报表',
      ActivityType::GUESS   => '美图猜猜报表',
      ActivityType::MICRO_AID => '微助力报表',
    }[activity_type_id.to_i]
    link_to(name, report_activities_path(activity_type_id: activity_type_id), options) if name
  end

  def biz_sidebar?
    return true if ['votes', 'surveys', 'groups'].include? params[:action]
    return true if @activity && BIZ_ACTIVITY_IDS.include?(@activity.activity_type_id)
    return true if BIZ_ACTIVITY_IDS.include?(params[:activity_type_id].to_i)
  end

  def activity_sidebar_name
    biz_sidebar? ? 'sidebar_business' : 'sidebar_activity'
  end

  def marketing_activities?
    return true if controller_name =~ /fight|old_coupons|slots|guas|wheels|coupons|fans_games/
    return true if MARKETING_ACTIVITY_IDS.include?(params[:activity_type].to_i)
    return true if controller_name == 'red_packets'
    if controller_name == 'activities' || controller_name =~ /share_photo/
      return true if controller_name =~ /share_photo/
      return true if action_name =~ /index|old_coupons|guas|wheels|fights|hit_eggs|slot|aids/
      return true if action_name =~ /consumes|report/ && MARKETING_ACTIVITY_IDS.include?(params[:activity_type_id].to_i)
      return true if @activity && MARKETING_ACTIVITY_IDS.include?(@activity.activity_type_id)
    end

    return true if old_coupons_path? || guas_path? || wheels_path? || fights_path? || hit_eggs_path? || slots_path? || waves_path? || unfolds_path? || recommends_path? || guesses_path? || wx_cards_path? || brokerages_path? || red_packets_path?
  end

  def marketing_sites?
    return true if controller_name =~ /wx_walls|wx_wall_messages|wx_wall_user_prizes|wx_wall_datas|shake/
    return true if MARKETING_SITE_IDS.include?(params[:activity_type].to_i)
  end

  def business_management?
    return false if controller_name =~ /^vip_group/
    controller_name =~ /micro_shops|micro_shop_branches|donations|donation_orders|activity_forms|activity_enrolls|greet_cards|albums|group|kf_settings|staffs|wx_walls|prints|wbbs/i ||
    ['votes', 'groups', 'user_data', 'diagram', 'surveys'].include?(action_name) ||
    BIZ_ACTIVITY_IDS.include?(params[:activity_type]) ||
    BIZ_ACTIVITY_IDS.include?(@activity.try(:activity_type_id)) ||
    BIZ_ACTIVITY_IDS.include?(@activity_type_id.to_i)
  end

  def old_coupons_path?
    return true if controller_name =~ /old_coupons/
    return true if request.path == old_coupons_activities_path
  end

  def activities_path?
    return true if activities_path == request.path && !@activity.try(:wx_card?)
  end

  def coupons_path?
    return true if controller_name == 'coupons'
    return true if @activity.try(:coupon?)
  end

  def unfolds_path?
    return true if controller_name == 'unfolds'
    return true if request.path == unfolds_activities_path
  end

  def recommends_path?
    return true if controller_name == 'recommends'
    return true if request.path == recommends_activities_path
  end

  def guesses_path?
    return true if controller_name =~ /guesses|guess_activity_questions/
    return true if [params[:activity_type], params[:activity_type], @activity_type_id].compact.map!(&:to_i).include?(ActivityType::GUESS)
  end

  def wx_cards_path?
    return true if controller_name == 'wx_cards'
    return true if @activity.try(:wx_card?)
  end

  def brokerages_path?
    return true if %w(settings commission_types clients brokers commission_transactions).include?(controller_name)
  end

  def red_packets_path?
    return true if %w(packets releases reports).include?(controller_name)
  end

  def waves_path?
    return true if controller_name == 'waves'
    return true if action_name == 'waves'
    return true if @activity.try(:wave?)
    return true if params.values_at(:activity_type, :activity_type_id).include?(ActivityType::WAVE.to_s)
  end

  def guas_path?
    return true if controller_name =~ /guas/
    return true if request.path == guas_activities_path
    return true if @activity.try(:gua?)
    return true if params.values_at(:activity_type, :activity_type_id).include?(ActivityType::GUA.to_s)
  end

  def wheels_path?
    return true if controller_name =~ /wheels/
    return true if request.path == wheels_activities_path
    return true if @activity.try(:wheel?)
    return true if params.values_at(:activity_type, :activity_type_id).include?(ActivityType::WHEEL.to_s)
  end

  def hit_eggs_path?
    return true if controller_name =~ /hit_eggs/
    return true if request.path == hit_eggs_activities_path
    return true if @activity.try(:hit_egg?)
    return true if params.values_at(:activity_type, :activity_type_id).include?(ActivityType::HIT_EGG.to_s)
  end

  def slots_path?
    return true if controller_name =~ /slot/
    return true if request.path == slots_activities_path
    return true if @activity.try(:slot?)
    return true if params.values_at(:activity_type, :activity_type_id).include?(ActivityType::SLOT.to_s)
  end

  def aids_path?
    return true if controller_name =~ /aid/
    return true if request.path == aids_activities_path
    return true if @activity.try(:micro_aid?)
    return true if params.values_at(:activity_type, :activity_type_id).include?(ActivityType::MICRO_AID.to_s)
  end

  def fights_path?
    request.original_url =~ /fight/i || @activity.try(:activity_type_id)==ActivityType::FIGHT || @activity_type_id.to_i==ActivityType::FIGHT
  end

  def proxy_payments_path?
    pay_accounts_path? || pay_withdraws_path?  || pay_transactions_path? || balance_pay_transactions_path?
  end

  def apply_pay_withdraws_path?
    pay_withdraws_path? && action_name == 'apply'
  end

  def index_pay_withdraws_path?
    pay_withdraws_path? && action_name == 'index'
  end

  def pay_accounts_path?
    return true if controller_path == "pay/accounts"
  end

  def pay_withdraws_path?
    return true if controller_path == "pay/withdraws"
  end

  def pay_transactions_path?
    return true if request.path == pay_transactions_path
  end

  def balance_pay_transactions_path?
    request.path == balance_pay_transactions_path
  end

  def activity_type_name( activity_type_id )
    {
      ActivityType::GUA     => '刮刮卡抽奖',
      ActivityType::WHEEL   => '幸运大转盘',
      ActivityType::FIGHT   => '一战到底',
      ActivityType::GUESS   => '美图猜猜'
    }[ activity_type_id.to_i ]
  end

  def report_name( activity_type_id )
    {
      ActivityType::GUA     => '刮刮卡报表',
      ActivityType::WHEEL   => '大转盘报表',
      ActivityType::FIGHT   => '一战到底报表',
      ActivityType::HIT_EGG => '砸金蛋报表',
      ActivityType::SLOT    => '老虎机报表',
      ActivityType::WAVE    => '摇一摇抽奖报表',
      ActivityType::GUESS   => '美图猜猜报表',
      ActivityType::MICRO_AID => '微助力报表'
    }[ activity_type_id.to_i ]
  end

end
