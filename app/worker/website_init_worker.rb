class WebsiteInitWorker
  include Sidekiq::Worker
  sidekiq_options :queue => 'standard', :retry => false, :backtrace => true

  def perform(to_supplier_id)
    logger.info "**********start"
    now = Time.now

    if Rails.env.staging? || Rails.env.production?
      from_account_id = 73290
    else
      from_account_id = 35067
    end

    Account.transaction do
      from_user = Account.where(id: from_account_id).first || Account.first
      return puts "from user not exists" unless from_user
      
      to_user = Account.where(id: to_supplier_id).first
      return puts "to user not exists" unless to_user

      return puts "to user have website and website_menus" if to_user.try(:website).try(:website_menus).to_a.count > 0

      user_cloner = UserCloner.new(from_user.nickname)
      user_cloner.user = to_user
      # return puts "wx_mp_user not exists" unless to_user.wx_mp_user

      # 初始化公众号和微官网
      unless to_user.site.wx_mp_user
        to_user.site.wx_mp_user = WxMpUser.where(site_id: to_user.site.id).first_or_create(name: to_user.nickname)
      end

      # wx_mp_user = create_wx_mp_user!(name: nickname) unless wx_mp_user
      # wx_mp_user.create_activity_for_website

      user_cloner.wx_mp_user = to_user.site.wx_mp_user

      time = to_user.created_at || Time.now

      user_cloner.clone_website
      user_cloner.clone_shops
      user_cloner.init_activity_by_coupon
      user_cloner.clone_activity_by_marketing(:gua, { ready_at: time, start_at: time + 1.hours, end_at: time + 30.days })
      user_cloner.init_activity_by_fans_game
    end

    logger.info "**********done, #{Time.now - now} seconds"
  end

end