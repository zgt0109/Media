class ActivityPrizeElementsController < ApplicationController
  before_filter :find_element, except: [:create]

  def create
    @element = ActivityPrizeElement.new(activity_id: params[:activity_id], name: '新元素', qiniu_pic_key: ActivityPrizeElement.default_qiniu_pic_key)
    if @element.save
      respond_to do |format|
        format.html {redirect_to :back}
      end
    end
  end

  def update
    @element.update_attributes(params[:activity_prize_element])
    respond_to do |format|
      format.js
      format.html {redirect_to :back}
    end
  end

  def destroy
    prizes = ActivityPrize.where(activity_id: @element.activity_id)
    exists_element_ids = prizes.pluck(:activity_element_ids).reject(&:blank?).map{|ids| ids.split(',') }
    has_used = exists_element_ids.flatten.uniq.include?(@element.id.to_s)
    return redirect_to :back, alert: '已经被使用，不能删除' if has_used

    @element.destroy
    respond_to do |format|
      format.html {redirect_to :back}
    end
  end

  private
    def find_element
      @element = ActivityPrizeElement.find(params[:id])
    end
end
