class Govmailbox < ActiveRecord::Base
	belongs_to :activity
	has_many :govmails
	validates :name, presence: true
	enum_attr :status, in: [
		['normal',  1, '默认'],
		['deleted', 0, '已删除']
	]

	def logo_url
		qiniu_image_url(qiniu_logo_key).presence || '/assets/email.jpg'
	end

	def display_incomes
		incomes_basecount.to_i + govmails.roots.count
	end

	def display_replies
	     replies_basecount.to_i + govmails.replies.count
	end

end
