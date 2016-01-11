class WxRequest < ActiveRecord::Base

  belongs_to :site

  class << self

    def fetch_from_wx_logs(date, site_id)
      wr = WxRequest.where(:date => date.to_s, :site_id => site_id).first
      unless wr
        site = Site.where(:id => site_id).first
        if site
          h = WxLog.site_data_by_date(date, site.uid)
          WxRequest.create(h.merge(:date => date.to_s, :site_id => site_id))
        end
      end
    end

    def fetch_yesterday_wx_logs
      date = Date.yesterday
      sites = Site.all
      sites.each do |site|
        self.fetch_from_wx_logs(date, site.id)
      end
    end

    def fetch_this_month_wx_logs
      ed = Date.yesterday
      st = ed.beginning_of_month
      dates = (st..ed)
      sites = Site.all
      dates.each do |date|
        sites.each do |site|
          self.fetch_from_wx_logs(date, site.id)
        end
      end
    end

    #命中分析首次部署后执行
    def update_data
      WxRequest.find_each do |wr|
        site = Site.where(id: wr.site_id).first
        if site
          h = WxLog.site_data_by_date(wr.date, site.uid)
          wr.update_attributes(h.merge(date: date.to_s, site_id: site_id))
        end
      end
    end

  end

end