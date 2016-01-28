namespace :stat do


  # begin_date =Date.yesterday
  #
  # end_date =Date.today



  begin_date =Date.yesterday

  end_date =Date.today

  task get_data:[
           :create_wx_user_data,
           :create_wx_articles_data,
           :create_wx_articles_hour_data,
           :create_wx_msg_data,
           :create_wx_msg_hour_data,


  ]

  task :create_wx_user_data => :environment do

    puts "update data now....."
    @wx_mp_user = WxMpUser.all

    @wx_mp_user.each_with_index do |w, index|
      options={:openid => w.openid, :begin_date => (begin_date-1).to_s, :end_date => (end_date-1).to_s}

      puts options

      cumulate = WxUserData.getusercumulate(options)["list"]

      usersummary = WxUserData.getusersummary(options)["list"]

      usersummary.each do |d|

        puts d

        stat = StatWxUser.where(:ref_date => d["ref_date"], :openid => w.openid, :user_source => d["user_source"]).first_or_create()


        stat.update_attributes(:cancel_user => d["cancel_user"], :ref_date => d["ref_date"], :new_user => d["new_user"])

      end

      cumulate.each do |c|
        puts c

        stat = StatWxUser.where(:ref_date => c["ref_date"], :openid => w.openid, :user_source => c["user_source"]).first_or_create()

        stat.update_attributes(:cumulate_user => c["cumulate_user"], :ref_date => c["ref_date"])
      end

    end

    puts "finish!"
  end


  task :create_wx_articles_data => :environment do

    @wx_mp_user = WxMpUser.all
    @wx_mp_user.each_with_index do |w, index|



      options={:openid => w.openid, :begin_date => (begin_date).to_s, :end_date => (begin_date).to_s}
      # 获取图文群发每日数据
      a_sum = WxUserData.getarticlesummary(options)["list"]
      # # # 获取图文群发总数据
      # puts a_total =WxUserData.getarticletotal(options)
      # # # 获取图文统计数据
      # puts a_userread = WxUserData.getuserread(options)["list"]
      # # 获取图文分享转发数据
      # puts a_usershare = WxUserData.getusershare(options)["list"]
      a_sum.each do |a|

        puts a

        stat = StatWxArticle.where(:openid => w.openid, :ref_date => a["ref_date"],:user_source => a["user_source"], :msgid => a["msgid"], :title => a["title"]).first_or_create()

        stat.update_attributes(:int_page_read_user => a["int_page_read_user"], :int_page_read_count => a["int_page_read_count"],
                               :add_to_fav_user => a["add_to_fav_user"], :ori_page_read_user => a["ori_page_read_user"],
                               :ori_page_read_count => a["ori_page_read_count"], :share_scene => a["share_scene"],
                               :share_user => a["share_user"], :share_count => a["share_count"], :add_to_fav_count => a["add_to_fav_count"],
                               :target_user => a["target_user"])

      end


    end

  end

  task :create_wx_articles_hour_data => :environment do


    @wx_mp_user = WxMpUser.all
    @wx_mp_user.each_with_index do |w, index|

      options={:openid => w.openid, :begin_date => (begin_date).to_s, :end_date => (begin_date).to_s}

      # # 获取图文统计分时数据
      a_userread_hour = WxUserData.getuserreadhour(options)["list"]

      # # 获取图文分享转发分时数据
      # a_usershare_hour = WxUserData.getusersharehour(options)["list"]
      a_userread_hour.each do |a|

        puts a

        @article = StatWxArticle.find_by_ref_date(a["ref_date"])


        stat = StatWxHourArticle.where(:openid => w.openid, :ref_hour => a["ref_hour"], :user_source => a["user_source"], :ref_date => a["ref_date"], :msgid => @article.msgid, :title => @article.title).first_or_create()

        stat.update_attributes(:int_page_read_user => a["int_page_read_user"], :int_page_read_count => a["int_page_read_count"],
                               :add_to_fav_user => a["add_to_fav_user"], :ori_page_read_user => a["ori_page_read_user"],
                               :ori_page_read_count => a["ori_page_read_count"], :share_scene => a["share_scene"],
                               :share_user => a["share_user"], :share_count => a["share_count"], :add_to_fav_count => a["add_to_fav_count"],
                               :target_user => a["target_user"])

      end
    end
  end

  task :create_wx_msg_data => :environment do

    @wx_mp_user = WxMpUser.all

    @wx_mp_user.each_with_index do |w, index|

      options={:openid => w.openid, :begin_date => (begin_date-1).to_s, :end_date => (end_date-1).to_s}
      # 获取消息发送概况数据
      m_upstream = WxUserData.getupstreammsg(options)["list"]
      # 获取消息分送分时数据
      m_upstream_hour = WxUserData.getupstreammsghour(options)["list"]
      # 获取消息发送周数据
      # puts m_upstreammsg_week = WxUserData.getupstreammsgweek(options)
      # 获取消息发送月数据
      # puts m_upstreammsg_month = WxUserData.getupstreammsgmonth(options)
      # 获取消息发送分布数据
       m_upstreammsgdist = WxUserData.getupstreammsgdist(options)["list"]
      # 获取消息发送分布周数据
      # puts m_upstreammsgdist_week = WxUserData.getupstreammsgdistweek(options)
      # 获取消息发送分布月数据
      # puts m_upstreammsgdist_month = WxUserData.getupstreammsgdistmonth(options)

      m_upstream.each do |m|
        stat = StatWxMsg.where(:ref_date => m["ref_date"], :openid => w.openid, :user_source => m["user_source"], :msg_type => m["msg_type"]).first_or_create()
        #
        stat.update_attributes(:msg_user => m["msg_user"], :msg_count => m["msg_count"])
      end

      m_upstreammsgdist.each do |m|

        stat = StatWxMsg.where(:ref_date => m["ref_date"], :openid => w.openid, :msg_user => m["msg_user"], :user_source => m["user_source"]).first_or_create()

        stat.update_attributes(:count_interval => m["count_interval"])

      end


    end

  end
  task :create_wx_msg_hour_data => :environment do

    @wx_mp_user = WxMpUser.all


    @wx_mp_user.each_with_index do |w, index|

      options={:openid => w.openid, :begin_date => (begin_date).to_s, :end_date => (begin_date).to_s}
      # 获取消息发送概况数据
      m_upstream = WxUserData.getupstreammsg(options)["list"]
      # 获取消息分送分时数据
      puts m_upstream_hour = WxUserData.getupstreammsghour(options)["list"]
      # 获取消息发送周数据
      # puts m_upstreammsg_week = WxUserData.getupstreammsgweek(options)
      # 获取消息发送月数据
      # puts m_upstreammsg_month = WxUserData.getupstreammsgmonth(options)
      # 获取消息发送分布数据
      m_upstreammsgdist = WxUserData.getupstreammsgdist(options)["list"]
      # 获取消息发送分布周数据
      # puts m_upstreammsgdist_week = WxUserData.getupstreammsgdistweek(options)
      # 获取消息发送分布月数据
      # puts m_upstreammsgdist_month = WxUserData.getupstreammsgdistmonth(options)
      puts options

      m_upstream_hour.each do |m|

        stat = StatWxHourMsg.where(:ref_date => m["ref_date"], :ref_hour => m["ref_hour"], :openid => w.openid, :user_source => m["user_source"], :msg_type => m["msg_type"]).first_or_create()
        #
        stat.update_attributes(:msg_user => m["msg_user"], :msg_count => m["msg_count"])
      end
      #
      m_upstreammsgdist.each do |m|

        stat = StatWxHourMsg.where(:ref_date => m["ref_date"], :openid => w.openid, :msg_user => m["msg_user"], :user_source => m["user_source"]).first_or_create()

        stat.update_attributes(:count_interval => m["count_interval"])

      end


    end

  end


end

