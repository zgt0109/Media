class WxLog

  include Mongoid::Document

  class << self

    def add_log(params={})
      params.symbolize_keys!
      xml = (params[:xml] || {}).symbolize_keys!
      xml[:RequestMsg] = params[:RequestMsg]
      xml[:ReplyMsg] = params[:ReplyMsg]
      xml[:IsSuccess] = params[:IsSuccess]
      xml[:KeyWord] = params[:KeyWord]
      xml[:ConnectTime] = params[:ConnectTime]
      create_time = xml[:CreateTime].to_i
      xml[:CreateTime] = Time.at(create_time) if create_time > 0
      WxLog.create(xml) if xml.present?
    end

    def by_date(date)
      st = Time.parse(date.to_s + " 0:0:0")
      ed = Time.parse(date.tomorrow.to_s + " 0:0:0")
      self.where(:CreateTime.gte => st, :CreateTime.lte => ed)
    end

    def by_date_hours(date)
      st = Time.parse(date.to_s + " 0:0:0")
      ed = Time.parse(date.tomorrow.to_s + " 0:0:0")
      self.where(:CreateTime.gte => st, :CreateTime.lte => ed)
    end

    def get_data_by_date(date)

      map = %Q{
        function() {
          emit(this.ToUserName, {count: 1})
        }
      }

      reduce = %Q{
        function(key, values) {
          var result = {count: 0};
          values.forEach(function(value) {
            result.count += value.count;
          });
          return result;
        }
      }

      result = {}
      logs = WxLog.by_date(date)

      # 累积总请求数
      result[:total_requests] = WxLog.count

      # 总商家数
      result[:total_suppliers] = Supplier.normal_account.count

      # 日总请求数
      result[:daily_requests] = logs.count

      groups = logs.map_reduce(map, reduce).out(inline: true).map{|e| {:supplier => e["_id"], :requests => e["value"]["count"].to_i}}

      # 有请求商户数
      result[:daily_suppliers] = groups.count

      # 平均请求数
      result[:daily_avg_requests] = result[:daily_suppliers] > 0 && (result[:daily_requests] / result[:daily_suppliers]) || 0

      top_100_logs = groups.sort_by{|a| -a[:requests]}[0..99]

      # 日请求最大商家
      result[:daily_max_supplier] = top_100_logs.first.try(:[], :supplier)

      # 日请求最大数据
      result[:daily_max_supplier_requests] = top_100_logs.first.try(:[], :requests) || 0

      requests_sum = top_100_logs.sum{|t| t[:requests]}
      requests_times = top_100_logs.count

      result[:top100_avg_requests] = requests_times > 0 && (requests_sum / requests_times) || 0

      result
    end

    def by_uid(uid)
      self.where(:ToUserName => uid)
    end

    def supplier_data_by_date(date, uid)
      h = {:text => 0, :event => 0, :image => 0, :voice => 0, :video => 0, :location => 0, :link => 0}
      map, reduce = self.set_map_and_reduce("this.MsgType")
      wx_logs = self.by_uid(uid).by_date(date)
      groups = wx_logs.map_reduce(map, reduce).out(inline: true).map{|e| {e["_id"] => e["value"]["count"].to_i}}
      groups.each do |day_datas|
        day_datas.each do |data|
          h[data.first.to_sym] = data.last
        end
      end

      message_users = []
      h.each{|k, v|
        unless k.to_s == 'event'
          message_users << self.by_uid(uid).by_date(date).where(:MsgType => k.to_s).collect(&:FromUserName)
          h[:message_nums] = h[:message_users].to_i + h[k]
        end
      }
      h[:message_users] = message_users.uniq.count
      h[:message_user_mean] = h[:message_users] == 0 ? 0 : h[:message_nums].to_f / h[:message_users]
      h[:total] = h[:text] + h[:event] + h[:image] + h[:voice] + h[:video] + h[:location] + h[:link]
      h[:text_hit] = self.by_uid(uid).by_date(date).where(:MsgType => 'text', :IsSuccess => 1).count
      h[:keyword_per] = h[:text_hit] == 0 ? 0 : h[:text_hit].to_f / h[:message_nums]
      h[:subscribe] = self.by_uid(uid).by_date(date).where(:MsgType => 'event', :Event => 'subscribe').count
      h[:unsubscribe] = self.by_uid(uid).by_date(date).where(:MsgType => 'event', :Event => 'unsubscribe').count
      h[:increase] = h[:subscribe] - h[:unsubscribe]
      h
    end

    def supplier_data_by_date_hours(date, uid)
      h = {:text => 0, :event => 0, :image => 0, :voice => 0, :video => 0, :location => 0, :link => 0}
      map, reduce = self.set_map_and_reduce("this.MsgType")
      wx_logs = self.by_uid(uid).by_date(date)
      groups = wx_logs.map_reduce(map, reduce).out(inline: true).map{|e| {e["_id"] => e["value"]["count"].to_i}}
      groups.each do |day_datas|
        day_datas.each do |data|
          h[data.first.to_sym] = data.last
        end
      end
      h[:total] = h[:text] + h[:event] + h[:image] + h[:voice] + h[:video] + h[:location] + h[:link]
      h[:subscribe] = self.by_uid(uid).by_date(date).where(:MsgType => 'event', :Event => 'subscribe').count
      h[:unsubscribe] = self.by_uid(uid).by_date(date).where(:MsgType => 'event', :Event => 'unsubscribe').count
      h[:increase] = h[:subscribe] - h[:unsubscribe]
      h
    end

    def multi_line(categories, hash_datas, title = "接口请求报告", y_text = "请求次数", type = 'seven')
      minTickInterval = categories.count > 7 ? ((categories.count / 6) + 1) : nil
      @chart = LazyHighCharts::HighChart.new('chart_basic_line') do |f|
        f.chart({ type: 'spline'})
        f.title({ text: title})
        f.credits({enabled: false})
        f.xAxis({
            categories: categories.count == 1 ? (0..23).map{|d| "#{d}h"} : categories.map{|d| "#{d.month}/#{d.day}"},
            minTickInterval: minTickInterval
          })
        f.yAxis({
            title:{text: y_text},

        })
        f.tooltip({
            crosshairs: true,
            shared: true
          })

        f.plotOptions({
            spline: {
                marker: {
                    radius: 2,
                    lineColor: '#666666',
                    lineWidth: 1
                }
            }
        })
        f.legend({
            layout: 'horizontal',
            align: 'center',
            width: hash_datas.keys.count > 1 ? 310 : nil
        })
        hash_datas.keys.each do |key|
          f.series({
              name: key,
              #yAxis: 0,
              marker: {
                  symbol: 'circle'
              },
              data: hash_datas[key].values
            })
        end

      end
    end

    def set_map_and_reduce(target = "this.ToUserName")
      map = %Q{
        function() {
          emit(#{target}, {count: 1})
        }
      }

      reduce = %Q{
        function(key, values) {
          var result = {count: 0};
          values.forEach(function(value) {
            result.count += value.count;
          });
          return result;
        }
      }
      [map, reduce]
    end

    #更新wx_log的IsSuccess字段（#命中分析首次部署后执行）
    def update_is_success
      WxLog.find_each do |wl|
        wl.update_attribute(IsSuccess: 1) unless wl['IsSuccess']
      end
    end

  end

  def supplier_name
    self["ToUserName"].present? && WxMpUser.where(:uid => self.ToUserName).first.try(:name) || "未知商户"
  end

end