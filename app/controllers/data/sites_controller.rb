# -*- encoding : utf-8 -*-
class Data::SitesController < ApplicationController
  before_filter only: :index do
    @partialLeftNav = "/layouts/partialLeftDC"
  end

  def index
    @region = params[:region] || "recent_7"
    @sort = params[:sort] ||"nb_actions"
    @sorts = PiwikSite::SORTS
    @categories = []
    @data = []
    @daterange = params[:daterange] || %Q(#{Date.today.to_s} - #{Date.today.to_s})
    @date_list= @daterange.split(" - ").map{|d| Date.parse d}

    @today_piwik = current_site.piwik_by_date(Date.today)
    @yesterday_piwik = current_site.piwik_by_date(Date.yesterday)

    # @today_data = HashWithIndifferentAccess.new current_site.daily_piwik_data(Date.today)
    # @yesterday_data = HashWithIndifferentAccess.new current_site.daily_piwik_data(Date.yesterday)
    # if ["today", "yesterday"].include?(@region )
    #   @sort = "nb_actions" if @sort == "avg_time_on_site"
    #   @piwiks = current_site.hour_piwik_data(Date.send(@region))
    #   @piwiks.each do |piwik|
    #     @categories << piwik["label"]
    #     if @sort == "bounce_rate"
    #       @data << (piwik["nb_visits"].to_i > 0 ? (piwik["bounce_count"].to_i / piwik["nb_visits"].to_i) * 100 : 0)
    #     else
    #       @data << piwik[@sort]
    #     end
    #   end

    #   if @categories.blank?
    #     @categories = (0..23).map{|i| "#{i}h"}
    #     @data = [0] * 24
    #   end
    # else
      @categories, @data = PiwikSite.get_recent_data(current_site.id, @sort, @region)
    # end
    # 只有最近7天和最近30天两种查询方式包含“平均停留时间”
    @sorts = PiwikSite::SORTS.merge("avg_time_on_site" => "平均停留时间")
    @chart = PiwikSite.base_line(@categories, @data, @sorts[@sort], {region: @region, date_list: @date_list}) if @categories.present?

    @piwik_sites = PiwikSite.where(:site_id => current_site.id).where(date: @date_list[0]..@date_list[1]).order('date desc').page(params[:page]).per(params[:per] || 10)

    #@entry_pages_labels = current_site.piwik_entry_pages_labels
    #@entry_pages_labels = [] if @entry_pages_labels.is_a?(Hash) && @entry_pages_labels["result"] == "error"
    respond_to do |format|
      format.html
      format.xls {
        send_data(xls_content_for(PiwikSite.where(:site_id => current_site.id).where(date: @date_list[0]..@date_list[1])),
                  :type => "text/excel;charset=utf-8; header=present",
                  :filename => "接口请求报告_#{Time.now.strftime("%Y%m%d")}.xls")
      }
    end
  end

  def yesterday
    @date = Date.yesterday
    @daily_data = current_site.daily_piwik_data(@date)
    @piwiks = current_site.hour_piwik_data(@date)
    render :action => "daily_data"
  end

  def recent_30
    @piwiks = PiwikSite.where(:site_id => current_site).order("date desc").limit(30)
  end

  def entrance
    @entry_pages_labels = current_site.piwik_entry_pages_labels
    @entry_pages_labels = [] if @entry_pages_labels.is_a?(Hash) && @entry_pages_labels["result"] == "error"
  end

  private

  def xls_content_for(datas)
    activity_enrolls__report = StringIO.new

    book = Spreadsheet::Workbook.new

    sheet1 = book.create_worksheet :name => "报表1"

    sheet1.row(0).default_format = nil

    sheet1.row(0).concat ['时间', "浏览量 PV", "访客数 UV", "跳出率 %", "平均停留时间 s"]

    count_row = 1
    datas.each do |data|
      sheet1.row(count_row).concat [data.date.to_date, data.nb_actions, data.nb_visits, data.bounce_rate, data.avg_time_on_site]

      count_row += 1
    end

    book.write activity_enrolls__report
    activity_enrolls__report.string
  end
end
