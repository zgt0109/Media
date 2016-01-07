class Biz::GovchatsController < ApplicationController
  before_filter :set_activity
  before_filter :find_chat, only: [:reply_modal, :reply, :author_modal, :remove, :archive]

  def conditions
    @search = @activity.custom_fields.normal.search(params[:search])
    @fields = @search.order(:position).page(params[:page]).per(20)
  end

  def reports
    @search = @activity.govchats.report.where("status != 0").roots.search(params[:search])
    @chats = @search.order("created_at DESC").page(params[:page]).per(20)
  end

  def complaints
    @search = @activity.govchats.complaint.where("status != 0").roots.search(params[:search])
    @chats = @search.order("created_at DESC").page(params[:page]).per(20)
  end

  def advises
    @search = @activity.govchats.advise.roots.where("status != 0").search(params[:search])
    @chats = @search.order("created_at DESC").page(params[:page]).per(20)
  end

  def author_modal
    render layout: "application_pop"
  end

  def edit_modal
    render layout: "application_pop"
  end

  def reply_modal
    render layout: "application_pop"
  end

  def update_activity_basecount
    params.each do |k,v|
      if k.include? 'basecount'
        @activity.extend.send(k+'=', v)
      end
      @activity.save
    end
    flash[:notice] = "保存成功"
    render inline: '<script>parent.document.location = parent.document.location;</script>';
  end

  def reply
    @activity.govchats.create(parent_id: @chat.id, body: params[:body], chat_type: @chat.chat_type)
    @chat.replied!
    flash[:notice] = "保存成功"
    render inline: '<script>parent.document.location = parent.document.location;</script>';
  end

  def archive
    @chat.archived!
    redirect_to :back, notice:'操作成功'
  end

  def remove
    @chat.deleted!
    redirect_to :back, notice:'操作成功'
  end

  private

  def find_chat
    @chat = @activity.govchats.find(params[:id])
  end

  def set_activity
    @activity = current_user.wx_mp_user.activities.govchat.show.first || current_user.wx_mp_user.create_activity_for_govchat
  end
end
