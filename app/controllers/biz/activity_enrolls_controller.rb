# -*- encoding : utf-8 -*-
class Biz::ActivityEnrollsController < ApplicationController
  # skip_filter :login_required

  def index
    @search = current_site.activities.show.where(activity_type_id: 10).order('id desc').search(params[:search])
    if params[:id].present?
      @activity             = current_site.activities.find(params[:id])
      @activity_id          = @activity.id
      @activity_enrolls     = @activity.activity_enrolls.order('id desc').page(params[:page])
      @activity_enrolls_all = @activity.activity_enrolls.order('id desc')
    elsif params[:search].present?
      @activity_id = current_site.activities.where(id: params[:search][:id_eq]).first.try :id
      activity_ids = @activity_id.presence || current_site.activities.where(activity_type_id: 10).show.pluck(:id)
      @activity_enrolls = ActivityEnroll.where(activity_id: activity_ids).where(["status > -2"]).order('id desc').page(params[:page])
      @activity_enrolls_all = ActivityEnroll.where(activity_id: activity_ids).where(["status > -2"]).order('id desc')
    else
      @activity_id = ""
      activity_ids = current_site.activities.where(activity_type_id: 10).show.pluck(:id)
      @activity_enrolls = ActivityEnroll.where(activity_id: activity_ids).where(["status > -2"]).order('id desc').page(params[:page])
      @activity_enrolls_all = ActivityEnroll.where(activity_id: activity_ids).where(["status > -2"]).order('id desc')
    end

    respond_to do |format|
      format.html
      format.xls
    end
  end

  def show
    activity = current_site.activities.where(id: params[:activity_id]).first
    @activity_enroll = activity.activity_enrolls.find(params[:id])
    @activity_forms = ActivityForm.where(activity_id: @activity_enroll.activity_id).order(:sort)
    render layout: 'application_pop'
  end

  def xls_content_for(objs)
    activity_enrolls__report = StringIO.new

    book = Spreadsheet::Workbook.new

    sheet1 = book.create_worksheet name: "activity_enrolls_1"

    sheet1.row(0).default_format = nil

    @activity = if params[:id].present?
      current_site.activities.find(params[:id])
    elsif params[:search][:id_eq].present?
      current_site.activities.find(params[:search][:id_eq])
    else
      objs.first.try(:activity)
    end

    unless @activity
      book.write activity_enrolls__report
      return activity_enrolls__report.string
    end

    columns = @activity.activity_forms.pluck(:field_value)
    field_names = @activity.activity_forms.pluck(:field_name)

    unless columns.present?
      book.write activity_enrolls__report
      return activity_enrolls__report.string
    end

    sheet1.row(0).concat columns + ['创建时间']

    count_row = 1
    objs.each do |obj|
      col = 0
      field_names.each do |field_name|
        sheet1[count_row, col] = obj.attrs(field_name)
        col += 1
      end
      sheet1[count_row, col] = obj.created_at
      count_row += 1
    end

    book.write activity_enrolls__report
    activity_enrolls__report.string
  end
  
end
