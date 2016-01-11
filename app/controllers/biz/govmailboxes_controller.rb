class Biz::GovmailboxesController < ApplicationController
  before_filter :set_activity_and_boxes
  before_filter :set_box, only: [:edit, :update, :remove, :mails, :edit_modal]

  def new
      @box = @activity.govmailboxes.new
      render layout: "application_pop"
  end

   def edit
      render layout: "application_pop"
  end

   def edit_modal
      @box.update_attributes(params[:govmailbox])
      render layout: "application_pop"
   end

  def create
    box = @activity.govmailboxes.create(params[:govmailbox])
    if box.present?
      flash[:notice] = "保存成功"
      render inline: '<script>parent.document.location = parent.document.location;</script>';
    else
      redirect_to :back, alert: '添加失败'
    end
  end

  def update
    if @box.update_attributes(params[:govmailbox])
      flash[:notice] = "保存成功"
      render inline: '<script>parent.document.location = parent.document.location;</script>';
    else
      redirect_to :back, alert: '操作失败'
    end
  end

  def remove
    @box.deleted!
    redirect_to :back, notice:'操作成功'
  end

   def mails
      @search = @box.govmails.roots.where("status != 0").search(params[:search])
      @mails = @search.page(params[:page]).per(20)
  end

  private

  def set_box
    @box = @activity.govmailboxes.find(params[:id])
  end

  def set_activity_and_boxes
    @activity = current_site.activities.govmail.show.first || current_site.create_activity_for_govmail
    @boxes = @activity.govmailboxes.normal.page(params[:page])
  end
end
