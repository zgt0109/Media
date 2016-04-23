# -*- coding: utf-8 -*-
class PrintsController < ApplicationController

  def index
    @print = current_user.print || current_user.build_print
    if @print.new_record? || @print.printers_for(current_site.id).count == 0
      @print = current_site.build_activities_for_print
    end
  end

  def create
    @print = Print.new(params[:print])
    if @print.save
      redirect_to :back, notice: '创建成功!'
    else
      render "index"
    end
  end

  def update
    @print = Print.find(params[:id])
    if @print.update_attributes(params[:print])
      redirect_to :back, notice: '更新成功!'
    else
      redirect_to :back, alert: '关键词不能重复!'
    end
  end

end
