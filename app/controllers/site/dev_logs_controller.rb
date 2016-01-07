# -*- coding: utf-8 -*-
class Site::DevLogsController < ApplicationController
  skip_before_filter *ADMIN_FILTERS

  layout 'dev_log'

  def index
    start_at = DevLog.vcl.order('created_at desc').first.created_at
    @dev_logs_hash = {}.tap{|h| start_at.year.downto(2013).each {|y| h[y] = DevLog.vcl.order('created_at desc').where("YEAR(created_at) = ?", y).entries }}
  end

  def oa
    start_at = DevLog.oa.order('created_at desc').first.created_at
    @dev_logs_hash = {}.tap{|h| start_at.year.downto(2014).each {|y| h[y] = DevLog.oa.order('created_at desc').where("YEAR(created_at) = ?", y).entries }}
    render 'index'
  end

  def fxt
    @is_fxt = true
    start_at = DevLog.fxt.order('created_at desc').first.created_at
    @dev_logs_hash = {}.tap{|h| start_at.year.downto(2015).each {|y| h[y] = DevLog.fxt.order('created_at desc').where("YEAR(created_at) = ?", y).entries }}
    render 'index'
  end

  def show
    @dev_log = DevLog.find(params[:id])
    if @dev_log.fxt?
      @is_fxt = true
      @next_def_log_id = DevLog.fxt.where("id > ?", @dev_log.id).order('id asc').first.try(:id)
      @pre_def_log_id = DevLog.fxt.where("id < ?", @dev_log.id).order('id desc').first.try(:id)
      @list_url = fxt_site_dev_logs_url
    elsif @dev_log.oa?
      @next_def_log_id = DevLog.oa.where("id > ?", @dev_log.id).order('id asc').first.try(:id)
      @pre_def_log_id = DevLog.oa.where("id < ?", @dev_log.id).order('id desc').first.try(:id)
      @list_url = oa_site_dev_logs_url
    else
      @next_def_log_id = DevLog.vcl.where("id > ?", @dev_log.id).order('id asc').first.try(:id)
      @pre_def_log_id = DevLog.vcl.where("id < ?", @dev_log.id).order('id desc').first.try(:id)
      @list_url = site_dev_logs_url
    end
  end

end
