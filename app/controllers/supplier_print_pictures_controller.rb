# -*- coding: utf-8 -*-
class SupplierPrintPicturesController < ApplicationController

  layout "application_pop"

  def index
    @supplier_print_client = SupplierPrintClient.find(params[:supplier_print_client_id])
    @supplier_print_picture = @supplier_print_client.supplier_print_picture || @supplier_print_client.build_supplier_print_picture
    @main_pics = []
    @main_pics = @supplier_print_client.main_pic_ids.split(";") if @supplier_print_client.main_pic_ids
  end

  def create
    @supplier_print_picture = SupplierPrintPicture.new(params[:supplier_print_picture])
    if @supplier_print_picture.save!
      redirect_to :back, notice: '创建成功!'
    else
      render action: "new"
    end
  end

  def update
    @supplier_print_picture = SupplierPrintPicture.find(params[:id])
    if @supplier_print_picture.update_attributes(params[:supplier_print_picture])
      redirect_to :back, notice: '更新成功!'
    else
      render action: "edit"
    end
  end

end
