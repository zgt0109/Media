class LeavingMessagesController < ApplicationController
  before_filter :set_activity, :set_message
  skip_before_filter :auth, :authorize

  def index
    @search = @messages.where(parent_id: nil).search(params[:search])
    @messages = @search.page(params[:page])
  end

  def create
    @message = current_user.leaving_messages.create(params[:leaving_message])
    parent = current_user.leaving_messages.find_by_id(params[:leaving_message][:parent_id])
    @children = parent.children.order('created_at DESC')
  end

  def check
    @message = @messages.find(params[:id])
    @message.check!
    redirect_to leaving_messages_path(page: params[:page])
  end

  def deny
    @message = @messages.find(params[:id])
    @message.deny!
    redirect_to leaving_messages_path(page: params[:page])
  end

  def edit_activity
  end

  def set_template
    @template = LeavingMessageTemplate.where(:supplier_id => current_user.id).first_or_create
  end

  def set_template_save
    @template = LeavingMessageTemplate.where(id: params[:template_id]).first
    @template.update_attribute(:template_id, params[:template_template_id]) if @template && params[:template_template_id]
    # @template.reload
    render :json => {:template_template_id => @template.template_id, :header_bg => @template.header_bg}
  end

  def set_header_bg
    @template = LeavingMessageTemplate.where(id: params[:template_id]).first
    @template.update_attribute(:header_bg, params[:header_bg]) if @template && params[:header_bg].present?
    render :json => {:header_bg => @template.header_bg}
  end

  def upload
    @template = LeavingMessageTemplate.where(id: params[:template_id]).first
    @template.pic = params[:files].try(:first)
    @template.header_bg = nil
    @template.save
    render :json => {:header_bg => @template.header_bg}
  end

  def update_activity
    @activities = current_user.activities.show.where(keyword: params[:activity][:keyword])
    if @activity.update_attributes(params[:activity])
      flash[:notice] = '保存成功'
    else
      flash[:alert] = "保存失败：#{@activity.errors.full_messages.join('，')}"
    end
    redirect_to edit_activity_leaving_messages_path
  end


  def destroy
    @message = @messages.find(params[:id])
    @message.destroy
    respond_to do |format|
      format.html { redirect_to leaving_messages_path(page: params[:page]) }
      format.json { head :no_content }
    end
  end

  def edit
    @message = @messages.find(params[:id])
    @children = @message.children.order("id desc")
    render layout: 'application_pop'
  end

  def forbid_replier
    @message = @messages.find(params[:id])
    if @message.forbid_replier!
      flash[:notice] = "已拉黑该用户"
    end
    redirect_to leaving_messages_path(page: params[:page])
  end

  def cancel_forbid_replier
    @message = @messages.find(params[:id])
    if @message.cancel_forbid_replier!
      flash[:notice] = "已取消拉黑该用户"
    end
    redirect_to leaving_messages_path(page: params[:page])
  end

  private
    def set_message
      @messages = current_user.leaving_messages.order("created_at DESC") || []
    end
    def set_activity
      @activity = current_user.activities.setted.message.first_or_initialize(qiniu_pic_key: 'FvKEd9bIay1xGjCw4mEUSkrOZWmy')
    end

end
