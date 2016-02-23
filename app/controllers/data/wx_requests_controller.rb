# -*- encoding : utf-8 -*-
class Data::WxRequestsController < ApplicationController
  before_filter :require_wx_mp_user

  before_filter do
    @partialLeftNav = "/layouts/partialLeftDC"
  end

  before_filter :set_dates, :set_data, only: [:index, :subscribe, :article, :message, :keyword]

  def index
    @high_chart = {"文本请求" => {}, "图片请求" => {}, "事件请求" => {}, "全部请求" => {}}
    @data = {'today' => {}, 'yesterday' => {}, 'seven' => {}, 'month' => {}, 'all' => {}}

    #今日请求
    #@data['today']['文本请求'] = @today_wx_logs.where(:MsgType => 'text').count
    #@data['today']['图片请求'] = @today_wx_logs.where(:MsgType => 'image').count
    #@data['today']['事件请求'] = @today_wx_logs.where(:MsgType => 'event').count
    #@data['today']['全部请求'] = @today_wx_logs.count

    #全部
    total_wx_requests = @all_wx_requests.sum(:total) # + @data['today']['全部请求']
    @data['all']['全部请求'] = total_wx_requests
    #月请求
    @data['month']['全部请求'] = @month_wx_requests.sum(:total) # + @data['today']['全部请求']

    #周请求
    @data['seven']['全部请求'] = @seven_wx_requests.sum(:total) # + @data['today']['全部请求']

    #昨日请求
    @data['yesterday']['全部请求'] = @yesterday_wx_request.try(:total).to_i

    if @dates.count == 1

      (0..23).each do |date|
        @high_chart.keys.each do |key|
          @high_chart[key][date.to_s] = 0
        end
      end

      (0..23).each do |date|
        st = Time.parse(@st.to_s + " #{date}:0:0")
        ed = Time.parse(@st.to_s + " #{date + 1}:0:0")
        @high_chart["全部请求"][date.to_s] = @wx_logs.where(:CreateTime.gte => st, :CreateTime.lte => ed).count
      end

    else

      @dates.each do |date|
        @high_chart.keys.each do |key|
          @high_chart[key][date.to_s] = 0
        end
      end

      requests = @all_wx_requests.where(date: @st..@ed)
      requests.each do |r|
        @high_chart["文本请求"][r.date.to_s] = r.text
        @high_chart["图片请求"][r.date.to_s] = r.image
        @high_chart["事件请求"][r.date.to_s] = r.event
        @high_chart["全部请求"][r.date.to_s] = r.total
      end

      if Date.today <= @ed && Date.today >= @st
        #@high_chart['文本请求'][Date.today.to_s] = @data['today']['文本请求']
        #@high_chart['图片请求'][Date.today.to_s] = @data['today']['图片请求']
        #@high_chart['事件请求'][Date.today.to_s] = @data['today']['事件请求']
        #@high_chart['全部请求'][Date.today.to_s] = @data['today']['全部请求']
      end
    end

    @chart = WxLog.multi_line(@dates.to_a, {'全部请求' => @high_chart['全部请求']}, "#{@st.strftime("%Y-%m-%d")} 至 #{@ed.strftime("%Y-%m-%d")} 接口请求报告", "请求次数")

    if @dates.count == 1
      @high_chart['文本请求'][@ed.to_s] = @wx_logs.where(:MsgType => 'text').count
      @high_chart['图片请求'][@ed.to_s] = @wx_logs.where(:MsgType => 'image').count
      @high_chart['事件请求'][@ed.to_s] = @wx_logs.where(:MsgType => 'event').count
      @high_chart['全部请求'][@ed.to_s] = @wx_logs.count
    end

    @date_arrays = Kaminari.paginate_array(@dates.to_a.sort { |x, y| y<=>x }).page(params[:page])

    respond_to do |format|
      format.html
      format.xls {
        send_data(xls_content_for(@dates.to_a, @data, @high_chart),
                  :type => "text/excel;charset=utf-8; header=present",
                  :filename => "接口请求报告_#{Time.now.strftime("%Y%m%d")}.xls")
      }
    end
  end

  def subscribe

    @wx_mp_user = current_site.wx_mp_user

    @high_chart = {"关注数" => {}, "取消关注数" => {}, "净增长数" => {}, '累积关注' => {}}

    @data = {'today' => {}, 'yesterday' => {}, 'seven' => {}, 'month' => {}, 'all' => {}}

    #今日关注
    #@data['today']['关注数'] = @today_wx_logs.where(:MsgType => 'event', :Event => 'subscribe').count
    #@data['today']['取消关注数'] = @today_wx_logs.where(:MsgType => 'event', :Event => 'unsubscribe').count
    #@data['today']['净增长数'] = @data['today']['关注数'] - @data['today']['取消关注数']

    ##全部
    total_subscribes = @all_wx_requests.sum(:new_user) # + @data['today']['净增长数']

    # total_subscribes=300
    @data['all']['累积关注'] = @wx_mp_user.stats_wx_users.maximum("cumulate_user")

    #月关注

    month_request = @wx_mp_user.stats_wx_users.select('max(cumulate_user) total,sum(new_user) subscribe, sum(cancel_user) unsubscribe').first
    @data['month']['关注数'] = month_request.subscribe # + @data['today']['关注数']
    @data['month']['取消关注数'] = month_request.unsubscribe # + @data['today']['取消关注数']
    @data['month']['净增长数'] = month_request.subscribe.nil? ? 0 :month_request.subscribe-month_request.unsubscribe # + @data['today']['净增长数']

    #周关注
    week_request = @seven_wx_requests.select('max(cumulate_user) total, sum(new_user) subscribe, sum(cancel_user) unsubscribe').first
    @data['seven']['关注数'] = week_request.total # + @data['today']['关注数']
    @data['seven']['取消关注数'] = week_request.unsubscribe # + @data['today']['取消关注数']
    @data['seven']['净增长数'] = week_request.subscribe.nil? ? 0 : week_request.subscribe-week_request.unsubscribe # + @data['today']['净增长数']

    #昨日关注
    @data['yesterday']['关注数'] = @yesterday_wx_request.try(:new_user).to_i
    @data['yesterday']['取消关注数'] =@yesterday_wx_request.try(:cancel_user).to_i
    @data['yesterday']['净增长数'] = @yesterday_wx_request.try(:new_user).to_i-@yesterday_wx_request.try(:cancel_user).to_i

    # if @dates.count == 1
    #
    #   (0..23).each do |date|
    #     @high_chart.keys.each do |key|
    #       @high_chart[key][date.to_s] = 0
    #     end
    #   end
    #
    #   num = @high_chart["累积关注"][@ed.to_s]
    #   # (0..23).each do |date|
    #   #   st = Time.parse(@st.to_s + " #{date}:0:0")
    #   #   ed = Time.parse(@st.to_s + " #{date + 1}:0:0")
    #   #   @high_chart["关注数"][date.to_s] = @wx_logs.where(:MsgType => 'event', :Event => 'subscribe', :CreateTime.gte => st, :CreateTime.lte => ed).count
    #   #   @high_chart["取消关注数"][date.to_s] = @wx_logs.where(:MsgType => 'event', :Event => 'unsubscribe', :CreateTime.gte => st, :CreateTime.lte => ed).count
    #   #   @high_chart["净增长数"][date.to_s] = @high_chart["关注数"][date.to_s] - @high_chart["取消关注数"][date.to_s]
    #   #
    #   #   @high_chart["累积关注"][date.to_s] = num
    #   # end
    #
    # else
    #
    @dates.each do |date|
      @high_chart.keys.each do |key|
        @high_chart[key][date.to_s] = 0
      end
    end

    requests = @all_wx_requests.select('ref_date ref_date,max(cumulate_user) total, sum(new_user) subscribe ,sum(cancel_user) unsubscribe').where(ref_date: @st..@ed).group(:ref_date)
    requests.each do |r|
      @high_chart["关注数"][r.ref_date.to_s] = r.subscribe
      @high_chart["累积关注"][r.ref_date.to_s] = r.total
      @high_chart["取消关注数"][r.ref_date.to_s] = r.unsubscribe
      @high_chart["净增长数"][r.ref_date.to_s] = r.subscribe-r.unsubscribe
    end
    #
    if Date.today <= @ed && Date.today >= @st
      #@high_chart['关注数'][Date.today.to_s] = @data['today']['关注数']
      #@high_chart['取消关注数'][Date.today.to_s] = @data['today']['取消关注数']
      #@high_chart['净增长数'][Date.today.to_s] = @data['today']['净增长数']
      #@high_chart['累积关注'][Date.today.to_s] = @high_chart["累积关注"][Date.yesterday.to_s].to_i + @high_chart['净增长数'][Date.today.to_s].to_i
    end
    #
    #   num = 0
    #   @dates.each do |date|
    #     num += @high_chart["净增长数"][date.to_s]
    #     @high_chart["累积关注"][date.to_s] = num
    #   end
    # end

    @chart = WxLog.multi_line(@dates.to_a, @high_chart, "#{@st.strftime("%Y-%m-%d")} 至 #{@ed.strftime("%Y-%m-%d")} 用户关注报告", "关注次数")

    if @dates.count == 1
      @high_chart['关注数'][@ed.to_s] = @high_chart["关注数"][@ed.to_s]
      @high_chart['取消关注数'][@ed.to_s] = @high_chart["取消关注数"][@ed.to_s]
      @high_chart['净增长数'][@ed.to_s] = @high_chart['关注数'][@ed.to_s] - @high_chart['取消关注数'][@ed.to_s]
      @high_chart['累积关注'][@ed.to_s] =@high_chart['累积关注'][@ed.to_s]
    end

    @date_arrays = Kaminari.paginate_array(@dates.to_a.sort { |x, y| y<=>x }).page(params[:page])

    respond_to do |format|
      format.html
      format.xls {
        send_data(xls_content_for(@dates.to_a, @data, @high_chart),
                  :type => "text/excel;charset=utf-8; header=present",
                  :filename => "用户关注报告_#{Time.now.strftime("%Y%m%d")}.xls")
      }
    end
  end

  def message
    @wx_mp_user = current_site.wx_mp_user

    @high_chart = {"消息数" => {}, "用户数" => {}}

    @data = {'today' => {}, 'yesterday' => {}, 'seven' => {}, 'month' => {}, 'all' => {}, "week" => {}}

    @data['all']['累积消息'] = @wx_mp_user.stats_wx_msgs.sum("msg_count")

    #月关注
    month_request = @wx_mp_user.stats_wx_msgs.select('sum(msg_count) msg_count,sum(msg_user) msg_user,max(count_interval) count_interval,sum(int_page_read_count) page,sum(ori_page_read_user) origin').first
    @data['month']['消息数'] = month_request.msg_count
    # @data['month']['消息量区间'] = month_request.count_interval
    @data['month']['用户数'] = month_request.msg_user
    # @data['month']['图文阅读次数'] = month_request.page
    # @data['month']['原文页'] =month_request.origin

    #周关注
    week_request = @seven_wx_msg_requests.select('sum(msg_count) msg_count,sum(msg_user) msg_user,max(count_interval) count_interval,sum(int_page_read_count) page,sum(ori_page_read_user) origin').first
    @data['week']['消息数'] = week_request.msg_count
    # @data['week']['消息量区间'] = week_request.count_interval
    @data['week']['用户数'] = week_request.msg_user
    # @data['month']['图文阅读次数'] = week_request.page
    # @data['month']['原文页'] = week_request.origin

    #昨日关注
    # @data['yesterday']['消息量区间'] = @yesterday_wx_msg_request.try(:msg_count).to_i
    @data['yesterday']['消息数'] = @yesterday_wx_msg_request.try(:msg_count).to_i
    @data['yesterday']['用户数'] = @yesterday_wx_msg_request.try(:msg_user).to_i
    # @data['month']['图文阅读次数'] = @yesterday_wx_msg_request.try(:page).to_i
    # @data['month']['原文页'] =@yesterday_wx_msg_request.try(:origin).to_i

    @dates.each do |date|
      @high_chart.keys.each do |key|
        @high_chart[key][date.to_s] = 0
      end
    end

    requests = @all_wx_msg_requests.select('ref_date ref_date,sum(msg_user) msg_user,sum(int_page_read_count) page , sum(msg_count) msg_count,sum(ori_page_read_user) origin,max(count_interval) count_interval')
                   .where(ref_date: @st..@ed).group(:ref_date)
    requests.each do |r|
      @high_chart["用户数"][r.ref_date.to_s] = r.msg_user
      @high_chart["消息数"][r.ref_date.to_s] = r.msg_count
      # @high_chart["消息量区间"][r.ref_date.to_s] =r.count_interval
      # @high_chart["图文阅读次数"][r.ref_date.to_s] = r.page
      # @high_chart["原文页"][r.ref_date.to_s] = r.origin
    end
    #
    if Date.today <= @ed && Date.today >= @st

    end

    @chart = WxLog.multi_line(@dates.to_a, @high_chart, "#{@st.strftime("%Y-%m-%d")} 至 #{@ed.strftime("%Y-%m-%d")} 用户关注报告", "关注次数")

    if @dates.count == 1
      @high_chart['用户数'][@ed.to_s] = @high_chart['用户数'][@ed.to_s]
      @high_chart['消息数'][@ed.to_s] = @high_chart['消息数'][@ed.to_s]
      # @high_chart['消息区间'][@ed.to_s] = @high_chart['消息区间'][@ed.to_s]
      # @high_chart['图文阅读次数'][@ed.to_s] = @high_chart['图文阅读次数'][@ed.to_s]
      # @high_chart['原文页'][@ed.to_s] =@high_chart['原文页'][@ed.to_s]
    end

    @date_arrays = Kaminari.paginate_array(@dates.to_a.sort { |x, y| y<=>x }).page(params[:page])

    respond_to do |format|
      format.html
      format.xls {
        send_data(xls_content_for(@dates.to_a, @data, @high_chart),
                  :type => "text/excel;charset=utf-8; header=present",
                  :filename => "用户关注报告_#{Time.now.strftime("%Y%m%d")}.xls")
      }
    end
  end

  def message_hour

    date = params[:date].nil? ? Date.yesterday : params[:date]

    params[:date] = date

    @wx_mp_user = current_site.wx_mp_user

    @message_hour = @wx_mp_user.stats_wx_hour_msgs.where(:ref_date => date)

    @data={}

    @hours = (0..23)

    @high_chart = {"消息数" => {}, "用户数" => {}}

    @hours.each do |h|

      @high_chart["消息数"][h] = @message_hour.find_by_ref_hour(h*100).nil? ? 0 : @message_hour.find_by_ref_hour(h*100).msg_count

      @high_chart["用户数"][h] = @message_hour.find_by_ref_hour(h*100).nil? ? 0 : @message_hour.find_by_ref_hour(h*100).msg_user

    end
    @chart = WxLog.multi_line((0..0), @high_chart, "#{date} 0点 至 24点 用户关注报告", "关注次数")
    respond_to do |format|
      format.html
      format.xls {
        send_data(xls_content_for(@hours.to_a, @data, @high_chart),
                  :type => "text/excel;charset=utf-8; header=present",
                  :filename => "用户关注报告_#{Time.now.strftime("%Y%m%d")}.xls")
      }
    end
  end

  def article

    @wx_mp_user = current_site.wx_mp_user

    @high_chart = {"文章标题" => {}, "阅读用户" => {}, "阅读次数" => {}, "分享次数" => {}, "分享用户" => {}, "原文页" => {},
                   "原文阅读次数" => {}, "收藏用户" => {}, "收藏次数" => {}}

    @data = {'today' => {}, 'yesterday' => {}, 'seven' => {}, 'month' => {}, 'all' => {}, "week" => {}}

    @data['all']['累积消息'] = @wx_mp_user.stats_wx_articles.sum("int_page_read_count")


    #月关注
    month_request = @wx_mp_user.stats_wx_articles.select('sum(int_page_read_user) int_page_read_user,sum(int_page_read_count),int_page_read_count ').first
    @data['month']['阅读数'] = month_request.int_page_read_count
    # @data['month']['消息量区间'] = month_request.count_interval
    @data['month']['用户数'] = month_request.int_page_read_user
    # @data['month']['图文阅读次数'] = month_request.page
    # @data['month']['原文页'] =month_request.origin

    #周关注
   puts week_request = @seven_wx_article_requests.select('sum(int_page_read_user) int_page_read_user,sum(int_page_read_count) int_page_read_count').first
    @data['week']['阅读数'] = week_request.int_page_read_count
    # @data['week']['消息量区间'] = week_request.count_interval
    @data['week']['用户数'] = week_request.int_page_read_user
    # @data['month']['图文阅读次数'] = week_request.page
    # @data['month']['原文页'] = week_request.origin

    #昨日关注
    # @data['yesterday']['消息量区间'] = @yesterday_wx_msg_request.try(:msg_count).to_i
    @data['yesterday']['阅读数'] = @yesterday_wx_article_request.try(:int_page_read_count).to_i
    @data['yesterday']['用户数'] = @yesterday_wx_article_request.try(:int_page_read_user).to_i
    # @data['month']['图文阅读次数'] = @yesterday_wx_msg_request.try(:page).to_i
    # @data['month']['原文页'] =@yesterday_wx_msg_request.try(:origin).to_i

    @dates.each do |date|
      @high_chart.keys.each do |key|
        @high_chart[key][date.to_s] = 0
      end
    end

    requests = @all_wx_article_requests.select('ref_date ref_date, title title , sum(int_page_read_user) int_page_read_user,sum(int_page_read_count) page ,
 sum(share_count) share_count,sum(ori_page_read_user) origin,sum(ori_page_read_count) origin_count,
 sum(share_user) share_user, sum(add_to_fav_user) add_to_fav_user , sum(add_to_fav_count) add_to_fav_count ')
                   .where(ref_date: @st..@ed).group(:ref_date)
    requests.each do |r|
      @high_chart["文章标题"][r.ref_date.to_s] = r.title
      @high_chart["阅读用户"][r.ref_date.to_s] = r.int_page_read_user
      @high_chart["分享次数"][r.ref_date.to_s] = r.share_count
      @high_chart["分享用户"][r.ref_date.to_s] = r.share_user
      @high_chart["阅读次数"][r.ref_date.to_s] =r.page
      @high_chart["原文页"][r.ref_date.to_s] = r.origin
      @high_chart["原文阅读次数"][r.ref_date.to_s] = r.origin_count
      @high_chart["收藏用户"][r.ref_date.to_s] = r.add_to_fav_user
      @high_chart["收藏次数"][r.ref_date.to_s] = r.add_to_fav_count
    end
    #
    if Date.today <= @ed && Date.today >= @st

    end

    @chart = WxLog.multi_line(@dates.to_a, @high_chart, "#{@st.strftime("%Y-%m-%d")} 至 #{@ed.strftime("%Y-%m-%d")} 用户关注报告", "关注次数")

    if @dates.count == 1
      @high_chart['用户数'][@ed.to_s] = @high_chart['用户数'][@ed.to_s]
      @high_chart['消息数'][@ed.to_s] = @high_chart['消息数'][@ed.to_s]
      # @high_chart['消息区间'][@ed.to_s] = @high_chart['消息区间'][@ed.to_s]
      # @high_chart['图文阅读次数'][@ed.to_s] = @high_chart['图文阅读次数'][@ed.to_s]
      # @high_chart['原文页'][@ed.to_s] =@high_chart['原文页'][@ed.to_s]
    end

    @date_arrays = Kaminari.paginate_array(@dates.to_a.sort { |x, y| y<=>x }).page(params[:page])

    respond_to do |format|
      format.html
      format.xls {
        send_data(xls_content_for(@dates.to_a, @data, @high_chart),
                  :type => "text/excel;charset=utf-8; header=present",
                  :filename => "用户关注报告_#{Time.now.strftime("%Y%m%d")}.xls")
      }
    end


  end


  def article_hour
    date = params[:date].nil? ? Date.yesterday : params[:date]

    params[:date] = date

    @wx_mp_user = current_site.wx_mp_user

    @article_hour = @wx_mp_user.stats_wx_hour_articles.where(:ref_date => date)

    @data={}

    @hours = (0..23)

    @high_chart = {"阅读次数" => {}, "用户数" => {}, "分享次数" => {}, "分享人数" => {}, "收藏次数" => {}, "收藏人数" => {}}

    @hours.each do |h|

      @high_chart["阅读次数"][h] = @article_hour.find_by_ref_hour(h*100).nil? ? 0 : @article_hour.where(:ref_hour=> h*100).sum("int_page_read_count")

      @high_chart["用户数"][h] = @article_hour.find_by_ref_hour(h*100).nil? ? 0 : @article_hour.where(:ref_hour=>h*100).sum("int_page_read_count")

      @high_chart["分享次数"][h] = @article_hour.find_by_ref_hour(h*100).nil? ? 0 : @article_hour.where(:ref_hour=>h*100).sum("share_user")
      @high_chart["分享人数"][h] = @article_hour.find_by_ref_hour(h*100).nil? ? 0 : @article_hour.where(:ref_hour=>h*100).sum("share_count")

      @high_chart["收藏次数"][h] = @article_hour.find_by_ref_hour(h*100).nil? ? 0 : @article_hour.where(:ref_hour=>h*100).sum("add_to_fav_count")

      @high_chart["收藏人数"][h] = @article_hour.find_by_ref_hour(h*100).nil? ? 0 : @article_hour.where(:ref_hour=>h*100).sum("add_to_fav_user")
    end
    @chart = WxLog.multi_line((0..0), @high_chart, "#{date} 0点 至 24点 图文消息报告", "次数")
    respond_to do |format|
      format.html
      format.xls {
        send_data(xls_content_for(@hours.to_a, @data, @high_chart),
                  :type => "text/excel;charset=utf-8; header=present",
                  :filename => "用户关注报告_#{Time.now.strftime("%Y%m%d")}.xls")
      }
    end

  end

  def keyword
    # @high_chart = {"消息发送人数" => {}, "消息发送次数" => {}, "人均发送次数" => {}, '关键词触发数' => {}, '关键词命中率' => {}}
    # @data = {'today' => {}, 'yesterday' => {}, 'seven' => {}, 'month' => {}, 'all' => {}}
    #
    # @data['yesterday']['消息发送次数'] = @yesterday_wx_request.try(:message_nums).to_i
    # @data['yesterday']['消息发送人数'] = @yesterday_wx_request.try(:message_users).to_i
    # @data['yesterday']['关键词触发数'] = @yesterday_wx_request.try(:text_hit).to_i
    # @data['yesterday']['关键词命中率'] = @data['yesterday']['消息发送次数'] == 0 ? 0.0 : @data['yesterday']['关键词触发数'].to_f / @data['yesterday']['消息发送次数']
    #
    # @data['seven']['消息发送次数'] = @seven_wx_requests.sum(:message_nums)
    # @data['seven']['消息发送人数'] = @seven_wx_requests.sum(:message_users)
    # @data['seven']['关键词触发数'] = @seven_wx_requests.sum(:text_hit)
    # @data['seven']['关键词命中率'] = @data['seven']['消息发送次数'] == 0 ? 0.0 : @data['seven']['关键词触发数'].to_f / @data['seven']['消息发送次数']
    #
    # if @dates.count == 1
    #
    #   (0..23).each do |date|
    #     @high_chart.keys.each do |key|
    #       @high_chart[key][date.to_s] = 0
    #     end
    #   end
    #
    #   (0..23).each do |date|
    #     st = Time.parse(@st.to_s + " #{date}:0:0")
    #     ed = Time.parse(@st.to_s + " #{date + 1}:0:0")
    #     @high_chart["消息发送人数"][date.to_s] = 0 #@wx_logs.where(:MsgType => 'event', :Event => 'subscribe', :CreateTime.gte => st, :CreateTime.lte => ed).count
    #     @high_chart["消息发送次数"][date.to_s] = 0 #@wx_logs.where(:MsgType => 'event', :Event => 'unsubscribe', :CreateTime.gte => st, :CreateTime.lte => ed).count
    #     @high_chart["人均发送次数"][date.to_s] = 0 #
    #     @high_chart["关键词触发数"][date.to_s] = 0
    #     @high_chart["关键词命中率"][date.to_s] = 0
    #   end
    #
    # else
    #
    #   @dates.each do |date|
    #     @high_chart.keys.each do |key|
    #       @high_chart[key][date.to_s] = 0
    #     end
    #   end
    #
    #   requests = @all_wx_requests.where(date: @st..@ed)
    #   requests.each do |r|
    #     @high_chart["消息发送人数"][r.date.to_s] = r.message_users
    #     @high_chart["消息发送次数"][r.date.to_s] = r.message_nums
    #     @high_chart["人均发送次数"][r.date.to_s] = r.message_user_mean
    #     @high_chart["关键词触发数"][r.date.to_s] = r.text_hit
    #     @high_chart["关键词命中率"][r.date.to_s] = r.keyword_per
    #   end
    #
    #   if Date.today <= @ed && Date.today >= @st
    #     @high_chart['消息发送人数'][Date.today.to_s] = @data['today']['消息发送人数']
    #     @high_chart['消息发送次数'][Date.today.to_s] = @data['today']['消息发送次数']
    #     @high_chart['人均发送次数'][Date.today.to_s] = @data['today']['人均发送次数']
    #     @high_chart['关键词触发数'][Date.today.to_s] = @data['today']['关键词触发数']
    #     @high_chart['关键词命中率'][Date.today.to_s] = @data['today']['关键词命中率']
    #   end
    #
    # end
    #
    # if params[:VCFields] == 'message'
    #   @chart = WxLog.multi_line(@dates.to_a, {'消息数' => @high_chart['消息发送次数']}, "#{@st.strftime("%Y-%m-%d")} 至 #{@ed.strftime("%Y-%m-%d")} 消息数报告", "消息数")
    # else
    #   @chart = WxLog.multi_line(@dates.to_a, {'关键词触发' => @high_chart['关键词触发数']}, "#{@st.strftime("%Y-%m-%d")} 至 #{@ed.strftime("%Y-%m-%d")} 关键词触发数报告", "关键词触发数")
    # end
    #
    # if @dates.count == 1
    #   @high_chart['消息发送人数'][@ed.to_s] = 0
    #   @high_chart['消息发送次数'][@ed.to_s] = 0
    #   @high_chart['人均发送次数'][@ed.to_s] = 0
    #   @high_chart['关键词触发数'][@ed.to_s] = 0
    #   @high_chart['关键词命中率'][@ed.to_s] = 0
    # end
    # @ahs = WxRequestHit.where(is_hit: 1, date: 1.month.ago.to_date..Date.yesterday, wx_mp_user_id: @wx_mp_user.id).select("content, id").group("content").order("date desc").limit(10)
    # @mhs = WxRequestHit.where(is_hit: 0, date: 1.month.ago.to_date..Date.yesterday, wx_mp_user_id: @wx_mp_user.id).select("content, id").group("content").order("date desc").limit(10)
    #
    # @date_arrays = Kaminari.paginate_array(@dates.to_a.sort { |x, y| y<=>x }).page(params[:page])
    #
    # respond_to do |format|
    #   format.html
    #   format.xls {
    #     send_data(xls_content_for(@dates.to_a, @data, @high_chart),
    #               :type => "text/excel;charset=utf-8; header=present",
    #               :filename => "#{params[:VCFields] == 'message' ? '消息数' : '关键词触发'}_#{Time.now.strftime("%Y%m%d")}.xls")
    #   }
    # end
  end

  def hit
    @ahs = WxRequestHit.where(is_hit: 1, date: 1.month.ago.to_date..Date.yesterday, wx_mp_user_id: @wx_mp_user.id).where('content not in (?)', params[:content].split(',')).select("content, id").group("content").order("date desc").limit(10)
    str = ''
    @ahs.each do |ah|
      str = str + '<tr><td>' + ah.content + '</td><td>' + WxRequestHit.where(is_hit: 1, date: 1.month.ago.to_date..Date.yesterday, wx_mp_user_id: @wx_mp_user.id, content: ah.content).sum(:hit_count).to_s + '</td></tr>'
    end
    if str.blank?
      render js: "$('#ah_a').hide();"
    else
      render js: "$('#ah_a').attr('href', '#{activity_hit_operating_reports_path(content: (@ahs.collect(&:content) + params[:content].split(',')).join(','))}');$('#ah tr').last().after('#{str}');"
    end
  end

  def not_hit
    @mhs = WxRequestHit.where(is_hit: 0, date: 1.month.ago.to_date..Date.yesterday, wx_mp_user_id: @wx_mp_user.id).where('content not in (?)', params[:content].split(',')).select("content, id").group("content").order("date desc").limit(10)
    str = ''
    @mhs.each do |ah|
      str = str + '<tr><td>' + ah.content + '</td><td>' + WxRequestHit.where(is_hit: 0, date: 1.month.ago.to_date..Date.yesterday, wx_mp_user_id: @wx_mp_user.id, content: ah.content).sum(:hit_count).sum.to_s + '</td></tr>'
    end
    if str.blank?
      render js: "$('#mh_a').hide();"
    else
      render js: "$('#mh_a').attr('href', '#{message_hit_operating_reports_path(content: (@mhs.collect(&:content) + params[:content].split(',')).join(','))}');$('#mh tr').last().after('#{str}');"
    end
  end

  private

  def set_dates
    if params[:start_at_and_end_at].present?
      @st = Date.parse(params[:start_at_and_end_at].split(' - ').first)
      @ed = Date.parse(params[:start_at_and_end_at].split(' - ').last)
      #params[:xls_start_at_and_end_at] = [Date.parse(params[:start_at_and_end_at].split(' - ').first), Date.parse(params[:start_at_and_end_at].split(' - ').last)].join(' - ')
    else
      #@st = @ed = Date.today
      if params[:type].present?
        case params[:type]
          when 'seven' then
            @st = Date.today - 1.weeks
            @ed = Date.yesterday
          when 'month' then
            @st = Date.today - 1.month
            @ed = Date.yesterday
        end
      else
        @st = Date.today - 1.weeks
        @ed = Date.yesterday
      end
    end
    params[:start_at_and_end_at] = [@st, @ed].join(' - ')

    if (@st..@ed) == (Date.today..Date.today)
      params[:type] = 'today'
    elsif (@st..@ed) == (Date.yesterday..Date.yesterday)
      params[:type] = 'yesterday'
    elsif (@st..@ed) == ((Date.today - 1.weeks)..Date.yesterday)
      params[:type] = 'seven'
    elsif (@st..@ed) == ((Date.today - 1.month)..Date.yesterday)
      params[:type] = 'month'
    end

    @dates = (@st..@ed)
  end

  def set_data
    #今日
    #@today_wx_logs = WxLog.by_uid(@wx_mp_user.wx_mp_user.openid).by_date(Date.today)
    #全部
    @mp_user = current_site.wx_mp_user
    @all_wx_requests = current_site.wx_mp_user.stats_wx_users
    @all_wx_msg_requests = @mp_user.stats_wx_msgs
    @all_wx_article_requests =@mp_user.stats_wx_articles
    #月
    @month_wx_requests = @all_wx_requests.where(ref_date: 1.month.ago.to_date..Date.yesterday)
    @month_wx_msg_requests =@all_wx_msg_requests.where(ref_date: 1.month.ago.to_date..Date.yesterday)
    @month_wx_article_requests =@all_wx_article_requests.where(ref_date: 1.month.ago.to_date..Date.yesterday)
    #周
    @seven_wx_requests = @all_wx_requests.where(ref_date: 1.week.ago.to_date..Date.yesterday)
    @seven_wx_msg_requests = @all_wx_msg_requests.where(ref_date: 1.week.ago.to_date..Date.yesterday)
    @seven_wx_article_requests = @all_wx_article_requests.where(ref_date: 1.week.ago.to_date..Date.yesterday)
    #昨日
    @yesterday_wx_request = @all_wx_requests.where(ref_date: Date.yesterday..Date.today).first
    @yesterday_wx_msg_request = @all_wx_msg_requests.where(ref_date: Date.yesterday..Date.today).first
    @yesterday_wx_article_request = @all_wx_article_requests.where(ref_date: Date.yesterday..Date.today).first
    #某天
    if params[:type] == 'today'
      # @wx_logs = @today_wx_logs
    elsif params[:type] == 'yesterday'
      # @wx_logs = WxLog.by_uid(@wx_mp_user.wx_mp_user.openid).by_date(Date.yesterday)
      @day_request = @yesterday_wx_request
      @day_msg_request =@yesterday_wx_msg_request
      @day_article_request =@yesterday_wx_article_request
    elsif @dates.count == 1
      # @wx_logs = WxLog.by_uid(@wx_mp_user.openid).by_date(@st)
      @day_request = @all_wx_requests.where(ref_date: @st..@ed).first
      @msg_day_request = @all_wx_msg_requests.where(ref_date: @st..@ed).first
      @article_day_request = @all_wx_article_requests.where(ref_date: @st..@ed).first
    end

    params[:VCFields] ||= 'message'
  end

  def xls_content_for(dates, data, h)

    activity_enrolls__report = StringIO.new

    book = Spreadsheet::Workbook.new

    sheet1 = book.create_worksheet :name => "报表1"

    sheet1.row(0).default_format = nil

    if action_name == 'subscribes'
      sheet1.row(0).concat ['时间', "新关注人数", "取消关注人数", "净增关注人数", "累积关注人数"]
    elsif action_name == 'keyword'
      if params[:VCFields] == 'message'
        sheet1.row(0).concat ['时间', "消息发送人数", "消息发送次数", "人均发送次数"]
        h.delete_if { |k| ['关键词触发数', '关键词命中率'].include?(k) }
      else
        sheet1.row(0).concat ['时间', "消息发送次数", "关键词触发数", "关键词命中率"]
        h.delete_if { |k| ['消息发送人数', '人均发送次数'].include?(k) }
      end
    else
      sheet1.row(0).concat ['时间'] + h.keys
    end

    count_row = 1

    dates.each do |date|
      sheet1[count_row, 0] = date.to_s
      col = 1
      h.keys.each do |key|
        sheet1[count_row, col] = h[key][date.to_s]
        col += 1
      end
      count_row += 1
    end

    book.write activity_enrolls__report
    activity_enrolls__report.string
  end

end
