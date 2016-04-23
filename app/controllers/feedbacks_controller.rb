# -*- encoding : utf-8 -*-
class FeedbacksController < ApplicationController

  def index
    @feedbacks = current_site.feedbacks.order('created_at desc').page(params[:page])
    @feedback = current_site.feedbacks.new
  end

  def create
    @feedback = current_site.feedbacks.new(params[:feedback])

    if @feedback.save
      redirect_to feedbacks_url, notice: '提交成功'
    else
      redirect_to feedbacks_url, alert: '提交失败'
    end
  end

  def show
    @feedback = current_site.feedbacks.find(params[:id])
  end

end
