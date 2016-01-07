# -*- coding: utf-8 -*-
class SupplierPrintClientsController < ApplicationController

  def index
    @supplier_print_clients = current_user.supplier_print_clients
  end

  def edit
    @supplier_print_client = SupplierPrintClient.find_by_id(params[:id])
  end

  def update
    @supplier_print_client = SupplierPrintClient.find(params[:id])

    if @supplier_print_client.update_attributes!(params[:supplier_print_client])
      redirect_to supplier_print_clients_url, notice: '更新成功!'
    else
      redirect_to supplier_print_clients_url, notice: '更新失败!'
    end
    @supplier_print_client.connect_edit_webservice #链接inleader 更新数据
  end

  def update_pics
    @supplier_print_client = SupplierPrintClient.find(params[:id])
    if (params["att"] == "main_pic_ids")
      old_main_pics = @supplier_print_client["main_pic_ids"]
      if old_main_pics.blank?
        value = "#{params[:key]};"
      else
        value = "#{old_main_pics}#{params[:key]};"
      end
      # value = params[:key]
      @supplier_print_client.update_column(params["att"],value)
    else
      @supplier_print_client.update_column(params["att"],params[:key])
    end
    @supplier_print_client.connect_edit_ad
    respond_to do |format|
      format.js {}
    end
  end

  def delete_pics
    @supplier_print_client = SupplierPrintClient.find(params[:id])
    key = "#{params[:key]};"
    origin_key = @supplier_print_client["main_pic_ids"]
    new_key = origin_key.slice!(key)
    @supplier_print_client.update_column("main_pic_ids",origin_key)
    @supplier_print_client.connect_edit_ad
    respond_to do |format|
      format.js {}
    end
  end

  def update_temp
    @supplier_print_client = SupplierPrintClient.find(params[:id])
    @supplier_print_client.update_column("temp_id", params[:temp])
    @supplier_print_client.connect_edit_ad
    respond_to do |format|
      format.js {}
    end
  end

end
