# -*- encoding : utf-8 -*-
class OperatingReportsController < ApplicationController
  before_filter do
    @partialLeftNav = "/layouts/partialLeftDC"
  end
  # skip_filter :login_required

  before_filter :set_supplier
  before_filter :set_dates, only: [:index, :subscribes, :keyword]
  before_filter :set_data, only: [:index, :subscribes, :keyword]

  def index
    @high_chart = {"文本请求" => {}, "图片请求" => {}, "事件请求" => {}, "全部请求" => {}}
    @data = {'today' => {}, 'yesterday' => {}, 'seven' => {}, 'month' => {}, 'all' => {}}

    #今日请求
    #@data['today']['文本请求'] = @today_wx_logs.where(:MsgType => 'text').count
    #@data['today']['图片请求'] = @today_wx_logs.where(:MsgType => 'image').count
    #@data['today']['事件请求'] = @today_wx_logs.where(:MsgType => 'event').count
    #@data['today']['全部请求'] = @today_wx_logs.count

    #全部
    total_wx_requests = @all_wx_requests.sum(:total)# + @data['today']['全部请求']
    if Rails.env.production?
      total_wx_requests_2014 = ActiveRecord::Base.connection.execute("select sum(total) from wx_requests_2014 where supplier_id=#{@supplier.id}").first[0] || 0
      total_wx_requests_2015 = ActiveRecord::Base.connection.execute("select sum(total) from wx_requests_2015 where supplier_id=#{@supplier.id}").first[0] || 0
      total_wx_requests = total_wx_requests + total_wx_requests_2014 + total_wx_requests_2015
    end
    @data['all']['全部请求'] = total_wx_requests

    #月请求
    @data['month']['全部请求'] = @month_wx_requests.sum(:total)# + @data['today']['全部请求']

    #周请求
    @data['seven']['全部请求'] = @seven_wx_requests.sum(:total)# + @data['today']['全部请求']

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

    @chart = WxLog.multi_line(@dates.to_a, {'全部请求' => @high_chart['全部请求']}, "#{@st.strftime("%Y-%m-%d")} 至 #{@ed.strftime("%Y-%m-%d")} 接口请求报告",  "请求次数")

    if @dates.count == 1
      @high_chart['文本请求'][@ed.to_s] = @wx_logs.where(:MsgType => 'text').count
      @high_chart['图片请求'][@ed.to_s] = @wx_logs.where(:MsgType => 'image').count
      @high_chart['事件请求'][@ed.to_s] = @wx_logs.where(:MsgType => 'event').count
      @high_chart['全部请求'][@ed.to_s] = @wx_logs.count
    end



    @date_arrays = Kaminari.paginate_array(@dates.to_a.sort{|x, y| y<=>x}).page(params[:page])

    respond_to do |format|
      format.html
      format.xls {
        send_data(xls_content_for(@dates.to_a, @data, @high_chart),
                  :type => "text/excel;charset=utf-8; header=present",
                  :filename => "接口请求报告_#{Time.now.strftime("%Y%m%d")}.xls")
      }
    end
  end

  def subscribes
    @high_chart = {"关注数" => {}, "取消关注数" => {}, "净增长数" => {}, '累积关注' => {}}

    @data = {'today' => {}, 'yesterday' => {}, 'seven' => {}, 'month' => {}, 'all' => {}}

    #今日关注
    #@data['today']['关注数'] = @today_wx_logs.where(:MsgType => 'event', :Event => 'subscribe').count
    #@data['today']['取消关注数'] = @today_wx_logs.where(:MsgType => 'event', :Event => 'unsubscribe').count
    #@data['today']['净增长数'] = @data['today']['关注数'] - @data['today']['取消关注数']

    #全部
    total_subscribes = @all_wx_requests.sum(:increase)# + @data['today']['净增长数']
    if Rails.env.production?
      total_subscribes_2014 = ActiveRecord::Base.connection.execute("select sum(increase) from wx_requests_2014 where supplier_id=#{@supplier.id}").first[0] || 0
      total_subscribes_2015 = ActiveRecord::Base.connection.execute("select sum(increase) from wx_requests_2015 where supplier_id=#{@supplier.id}").first[0] || 0
      total_subscribes = total_subscribes + total_subscribes_2014 + total_subscribes_2015
    end
    @data['all']['累积关注'] = total_subscribes

    #月关注
    month_request = @month_wx_requests.select('sum(subscribe) subscribe, sum(unsubscribe) unsubscribe, sum(increase) increase').first
    @data['month']['关注数'] = month_request.subscribe# + @data['today']['关注数']
    @data['month']['取消关注数'] = month_request.unsubscribe# + @data['today']['取消关注数']
    @data['month']['净增长数'] = month_request.increase# + @data['today']['净增长数']

    #周关注
    week_request = @seven_wx_requests.select('sum(subscribe) subscribe, sum(unsubscribe) unsubscribe, sum(increase) increase').first
    @data['seven']['关注数'] = week_request.subscribe# + @data['today']['关注数']
    @data['seven']['取消关注数'] = week_request.unsubscribe# + @data['today']['取消关注数']
    @data['seven']['净增长数'] = week_request.increase# + @data['today']['净增长数']

    #昨日关注
    @data['yesterday']['关注数'] = @yesterday_wx_request.try(:subscribe).to_i
    @data['yesterday']['取消关注数'] = @yesterday_wx_request.try(:unsubscribe).to_i
    @data['yesterday']['净增长数'] = @yesterday_wx_request.try(:increase).to_i

    if @dates.count == 1

      (0..23).each do |date|
        @high_chart.keys.each do |key|
          @high_chart[key][date.to_s] = 0
        end
      end

      num = 0
      (0..23).each do |date|
          st = Time.parse(@st.to_s + " #{date}:0:0")
          ed = Time.parse(@st.to_s + " #{date + 1}:0:0")
          @high_chart["关注数"][date.to_s] = @wx_logs.where(:MsgType => 'event', :Event => 'subscribe', :CreateTime.gte => st, :CreateTime.lte => ed).count
          @high_chart["取消关注数"][date.to_s] = @wx_logs.where(:MsgType => 'event', :Event => 'unsubscribe', :CreateTime.gte => st, :CreateTime.lte => ed).count
          @high_chart["净增长数"][date.to_s] = @high_chart["关注数"][date.to_s] -  @high_chart["取消关注数"][date.to_s]
          num += @high_chart["净增长数"][date.to_s]
          @high_chart["累积关注"][date.to_s] = num
      end

    else

      @dates.each do |date|
        @high_chart.keys.each do |key|
          @high_chart[key][date.to_s] = 0
        end
      end

      requests = @all_wx_requests.where(date: @st..@ed)
      requests.each do |r|
        @high_chart["关注数"][r.date.to_s] = r.subscribe
        @high_chart["取消关注数"][r.date.to_s] = r.unsubscribe
        @high_chart["净增长数"][r.date.to_s] = r.increase
      end

      if Date.today <= @ed && Date.today >= @st
        #@high_chart['关注数'][Date.today.to_s] = @data['today']['关注数']
        #@high_chart['取消关注数'][Date.today.to_s] = @data['today']['取消关注数']
        #@high_chart['净增长数'][Date.today.to_s] = @data['today']['净增长数']
        #@high_chart['累积关注'][Date.today.to_s] = @high_chart["累积关注"][Date.yesterday.to_s].to_i + @high_chart['净增长数'][Date.today.to_s].to_i
      end

      num = 0
      @dates.each do |date|
        num += @high_chart["净增长数"][date.to_s]
        @high_chart["累积关注"][date.to_s] = num
      end

    end


    @chart = WxLog.multi_line(@dates.to_a, @high_chart, "#{@st.strftime("%Y-%m-%d")} 至 #{@ed.strftime("%Y-%m-%d")} 用户关注报告",  "关注次数")

    if @dates.count == 1
      @high_chart['关注数'][@ed.to_s] = @wx_logs.where(:MsgType => 'event', :Event => 'subscribe').count
      @high_chart['取消关注数'][@ed.to_s] = @wx_logs.where(:MsgType => 'event', :Event => 'unsubscribe').count
      @high_chart['净增长数'][@ed.to_s] = @high_chart['关注数'][@ed.to_s] - @high_chart['取消关注数'][@ed.to_s]
      @high_chart['累积关注'][@ed.to_s] = @high_chart['净增长数'][@ed.to_s]
    end




    @date_arrays = Kaminari.paginate_array(@dates.to_a.sort{|x, y| y<=>x}).page(params[:page])



    respond_to do |format|
      format.html
      format.xls {
        send_data(xls_content_for(@dates.to_a, @data, @high_chart),
                  :type => "text/excel;charset=utf-8; header=present",
                  :filename => "用户关注报告_#{Time.now.strftime("%Y%m%d")}.xls")
      }
    end
  end

  def keyword
    @high_chart = {"消息发送人数" => {}, "消息发送次数" => {}, "人均发送次数" => {}, '关键词触发数' => {}, '关键词命中率' => {}}
    @data = {'today' => {}, 'yesterday' => {}, 'seven' => {}, 'month' => {}, 'all' => {}}


    @data['yesterday']['消息发送次数'] = @yesterday_wx_request.try(:message_nums).to_i
    @data['yesterday']['消息发送人数'] = @yesterday_wx_request.try(:message_users).to_i
    @data['yesterday']['关键词触发数'] = @yesterday_wx_request.try(:text_hit).to_i
    @data['yesterday']['关键词命中率'] = @data['yesterday']['消息发送次数'] == 0 ? 0.0 : @data['yesterday']['关键词触发数'].to_f / @data['yesterday']['消息发送次数']

    @data['seven']['消息发送次数'] = @seven_wx_requests.sum(:message_nums)
    @data['seven']['消息发送人数'] = @seven_wx_requests.sum(:message_users)
    @data['seven']['关键词触发数'] = @seven_wx_requests.sum(:text_hit)
    @data['seven']['关键词命中率'] = @data['seven']['消息发送次数'] == 0 ? 0.0 : @data['seven']['关键词触发数'].to_f / @data['seven']['消息发送次数']

    if @dates.count == 1

      (0..23).each do |date|
        @high_chart.keys.each do |key|
          @high_chart[key][date.to_s] = 0
        end
      end

      (0..23).each do |date|
        st = Time.parse(@st.to_s + " #{date}:0:0")
        ed = Time.parse(@st.to_s + " #{date + 1}:0:0")
        @high_chart["消息发送人数"][date.to_s] = 0#@wx_logs.where(:MsgType => 'event', :Event => 'subscribe', :CreateTime.gte => st, :CreateTime.lte => ed).count
        @high_chart["消息发送次数"][date.to_s] = 0#@wx_logs.where(:MsgType => 'event', :Event => 'unsubscribe', :CreateTime.gte => st, :CreateTime.lte => ed).count
        @high_chart["人均发送次数"][date.to_s] = 0#
        @high_chart["关键词触发数"][date.to_s] = 0
        @high_chart["关键词命中率"][date.to_s] = 0
      end

    else

      @dates.each do |date|
        @high_chart.keys.each do |key|
          @high_chart[key][date.to_s] = 0
        end
      end

      requests = @all_wx_requests.where(date: @st..@ed)
      requests.each do |r|
        @high_chart["消息发送人数"][r.date.to_s] = r.message_users
        @high_chart["消息发送次数"][r.date.to_s] = r.message_nums
        @high_chart["人均发送次数"][r.date.to_s] = r.message_user_mean
        @high_chart["关键词触发数"][r.date.to_s] = r.text_hit
        @high_chart["关键词命中率"][r.date.to_s] = r.keyword_per
      end

      if Date.today <= @ed && Date.today >= @st
        @high_chart['消息发送人数'][Date.today.to_s] = @data['today']['消息发送人数']
        @high_chart['消息发送次数'][Date.today.to_s] = @data['today']['消息发送次数']
        @high_chart['人均发送次数'][Date.today.to_s] = @data['today']['人均发送次数']
        @high_chart['关键词触发数'][Date.today.to_s] = @data['today']['关键词触发数']
        @high_chart['关键词命中率'][Date.today.to_s] = @data['today']['关键词命中率']
      end

    end

    if params[:VCFields] == 'message'
      @chart = WxLog.multi_line(@dates.to_a, {'消息数' => @high_chart['消息发送次数']}, "#{@st.strftime("%Y-%m-%d")} 至 #{@ed.strftime("%Y-%m-%d")} 消息数报告",  "消息数")
    else
      @chart = WxLog.multi_line(@dates.to_a, {'关键词触发' => @high_chart['关键词触发数']}, "#{@st.strftime("%Y-%m-%d")} 至 #{@ed.strftime("%Y-%m-%d")} 关键词触发数报告",  "关键词触发数")
    end

    if @dates.count == 1
      @high_chart['消息发送人数'][@ed.to_s] = 0
      @high_chart['消息发送次数'][@ed.to_s] = 0
      @high_chart['人均发送次数'][@ed.to_s] = 0
      @high_chart['关键词触发数'][@ed.to_s] = 0
      @high_chart['关键词命中率'][@ed.to_s] = 0
    end
    @ahs = ActivityHit.where(date: 1.month.ago.to_date..Date.yesterday, supplier_id: @supplier.id).select("content, id").group("content").order("date desc").limit(10)
    @mhs = MessageHit.where(date: 1.month.ago.to_date..Date.yesterday, supplier_id: @supplier.id).select("content, id").group("content").order("date desc").limit(10)


    @date_arrays = Kaminari.paginate_array(@dates.to_a.sort{|x, y| y<=>x}).page(params[:page])

    respond_to do |format|
      format.html
      format.xls {
        send_data(xls_content_for(@dates.to_a, @data, @high_chart),
                  :type => "text/excel;charset=utf-8; header=present",
                  :filename => "#{params[:VCFields] == 'message' ? '消息数' : '关键词触发'}_#{Time.now.strftime("%Y%m%d")}.xls")
      }
    end

  end

  def activity_hit
    @ahs = ActivityHit.where(date: 1.month.ago.to_date..Date.yesterday, supplier_id: @supplier.id).where('content not in (?)', params[:content].split(',')).select("content, id").group("content").order("date desc").limit(10)
    str = ''
    @ahs.each do |ah|
      str = str + '<tr><td>' + ah.content + '</td><td>' + ActivityHit.where(date: 1.month.ago.to_date..Date.yesterday, supplier_id: @supplier.id, content: ah.content).sum(:hit).to_s + '</td></tr>'
    end
    if str.blank?
      render js: "$('#ah_a').hide();"
    else
      render js: "$('#ah_a').attr('href', '#{activity_hit_operating_reports_path(content: (@ahs.collect(&:content) + params[:content].split(',')).join(','))}');$('#ah tr').last().after('#{str}');"
    end
  end

  def message_hit
    @mhs = MessageHit.where(date: 1.month.ago.to_date..Date.yesterday, supplier_id: @supplier.id).where('content not in (?)', params[:content].split(',')).select("content, id").group("content").order("date desc").limit(10)
    str = ''
    @mhs.each do |ah|
      str = str + '<tr><td>' + ah.content + '</td><td>' + MessageHit.where(date: 1.month.ago.to_date..Date.yesterday, supplier_id: @supplier.id, content: ah.content).collect(&:hit).sum.to_s + '</td></tr>'
    end
    if str.blank?
      render js: "$('#mh_a').hide();"
    else
      render js: "$('#mh_a').attr('href', '#{message_hit_operating_reports_path(content: (@mhs.collect(&:content) + params[:content].split(',')).join(','))}');$('#mh tr').last().after('#{str}');"
    end
  end

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
    #@today_wx_logs = WxLog.by_uid(@supplier.wx_mp_user.uid).by_date(Date.today)
    #全部
    @all_wx_requests = WxRequest.where(supplier_id: @supplier.id)
    #月
    @month_wx_requests = @all_wx_requests.where(date: 1.month.ago.to_date..Date.yesterday)
    #周
    @seven_wx_requests = @all_wx_requests.where(date: 1.week.ago.to_date..Date.yesterday)
    #昨日
    @yesterday_wx_request = @all_wx_requests.where(date: Date.yesterday..Date.today).first
    #某天
    if params[:type] == 'today'
      @wx_logs = @today_wx_logs
    elsif params[:type] == 'yesterday'
      @wx_logs = WxLog.by_uid(@supplier.wx_mp_user.uid).by_date(Date.yesterday)
      @day_request = @yesterday_wx_request
    elsif @dates.count == 1
      @wx_logs = WxLog.by_uid(@supplier.wx_mp_user.uid).by_date(@st)
      @day_request =  @all_wx_requests.where(date: @st..@ed).first
    end

    params[:VCFields] ||= 'message'
  end

  def set_supplier
    @supplier = current_user
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
        h.delete_if{|k| ['关键词触发数', '关键词命中率'].include?(k)}
      else
        sheet1.row(0).concat ['时间', "消息发送次数", "关键词触发数", "关键词命中率"]
        h.delete_if{|k| ['消息发送人数', '人均发送次数'].include?(k)}
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
