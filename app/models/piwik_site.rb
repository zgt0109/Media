class PiwikSite < ActiveRecord::Base

  #SORTS = {"nb_actions" => "浏览量", "nb_visits" => "访客数", "nb_uniq_visitors" => "独立访客", "bounce_rate" => "跳出率"}
  SORTS = {"nb_actions" => "浏览量", "nb_uniq_visitors" => "独立访客", "bounce_rate" => "跳出率"}

  class << self

    def get_recent_data(site_id, sort, region = "recent_7")
      days = region.split("_").last.to_i
      h = {}
      categories = []
      data = []
      ((Date.yesterday - days)..Date.yesterday).each do |day|
        h[day] = 0
      end
      piwiks = PiwikSite.where(:site_id => site_id).order("date desc").limit(days)
      piwiks.each do |piwik|
        h[piwik.date] = piwik.try(sort) if ((Date.yesterday - days)..Date.yesterday).cover? piwik.date
      end
      h.each do |key, value|
        categories << key.try(:strftime, "%m/%d")
        data << value
      end
      [categories, data]
    rescue => error
      [ [], [] ]
    end

    def base_line(categories, data, serie_name, options = {})
      options = HashWithIndifferentAccess.new(options)
      if ("#{options[:region]}".split("_").last.to_i > 7)
        options[:minTickInterval] =  6
      elsif options[:region].present?
        options[:minTickInterval] =  1
      end
      if options[:date_list].present?
        options.reverse_merge!(title: options[:date_list].join(" 至 ") << " #{serie_name}报告 ", yTitle: "#{serie_name}")
      end
      options.reverse_merge!(title: '流量数据分析图', yTitle: '流量数据', showInLegend: true)

      LazyHighCharts::HighChart.new('basic_line') do |f|
        f.chart({ type: 'spline' })
        f.title({ text: options[:title]})
        f.xAxis({
            categories: categories,
            minTickInterval: options[:minTickInterval],
            tickmarkPlacement: "on"
          })
        f.yAxis({
            title:{text: options[:yTitle]},
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
              }]
          })
        f.tooltip({
            # valueSuffix: "份"
          })
        f.legend({
            layout: 'vertical'#,
            #align: 'right',
            #verticalAlign: 'top',
            #x: -5,
            #y: 100,
            #borderWidth: 0
          })
        f.series({
            showInLegend: options[:showInLegend],
            name: serie_name,
            data: data
          })
        f.plotOptions({
            spline: {
                marker: {
                    radius: 2
                }
            }
        })
      end
    end

    # 同步商户数据到统计网站
    def sync_sites_to_piwik
      results = []
      sites = Account.where(:piwik_domain_status => 1)
      i = 0
      sites.each do |site|
        site.add_domain_to_piwik
        i += 1
      end
      results << "已为 #{i} 个商家补充个性化域名"
      sites = Account.where(:piwik_site_id => nil)
      i = 0
      sites.each do |site|
        site.get_piwik_site_id
        i += 1
      end
      results << "已为 #{i} 个商家添加统计代码"
      results.join("，")
    end

    # 获取Piwik昨天统计数据
    def get_yesterday_piwik_data
      sites = Account.where(["piwik_site_id is not null"])
      i = 0
      date = Date.yesterday
      sites.each do |site|
        site.get_piwik_data(date)
        i += 1
      end
      "已获取 #{i} 个商家昨天的统计数据"
    end

    def server
      Rails.env.production? ? "tongji.winwemedia.com" : "tongjitest.winwemedia.com"
    end

    def token_auth
      "5eacd7bee509e3fc4b444c2fdfc179c9"
    end

    def domain
      M_HOST + '/'
    end

  end

end
