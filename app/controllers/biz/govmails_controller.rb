class Biz::GovmailsController < ApplicationController
	before_filter :set_activity
	before_filter :set_mail, only: [:reply_modal, :reply, :author_modal, :remove, :archive]

	def author_modal
		render layout: "application_pop"
	end

	def reply_modal
		render layout: "application_pop"
	end

	def reply
		Govmail.create(parent_id: @chat.id, body: params[:body], govmailbox_id: @chat.govmailbox_id)
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

	def mails

	end

	def conditions
        @search = @activity.custom_fields.normal.search(params[:search])
        @fields = @search.order(:position).page(params[:page]).per(20)
    end

	private
	def set_activity
		if current_site.activities.govmail.exists?
			@activity = current_site.activities.govmail.show.first
		else
			@activity = current_site.create_activity_for_govmail
		end
	end

	def set_mail
		@chat = Govmail.find(params[:id])
	end
end
