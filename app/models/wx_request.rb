class WxRequest < ActiveRecord::Base

  belongs_to :supplier

  class << self

    def fetch_from_wx_logs(date, supplier_id)
      wr = WxRequest.where(:date => date.to_s, :supplier_id => supplier_id).first
      unless wr
        supplier = Supplier.where(:id => supplier_id).first
        if supplier
          h = WxLog.supplier_data_by_date(date, supplier.uid)
          WxRequest.create(h.merge(:date => date.to_s, :supplier_id => supplier_id))
        end
      end
    end

    def fetch_yesterday_wx_logs
      date = Date.yesterday
      suppliers = Supplier.all
      suppliers.each do |supplier|
        self.fetch_from_wx_logs(date, supplier.id)
      end
    end

    def fetch_this_month_wx_logs
      ed = Date.yesterday
      st = ed.beginning_of_month
      dates = (st..ed)
      suppliers = Supplier.all
      dates.each do |date|
        suppliers.each do |supplier|
          self.fetch_from_wx_logs(date, supplier.id)
        end
      end
    end

    #命中分析首次部署后执行
    def update_data
      WxRequest.find_each do |wr|
        supplier = Supplier.where(id: wr.supplier_id).first
        if supplier
          h = WxLog.supplier_data_by_date(wr.date, supplier.uid)
          wr.update_attributes(h.merge(date: date.to_s, supplier_id: supplier_id))
        end
      end
    end

  end

end