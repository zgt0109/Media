module VoteHelper
	def list_ul_css(activity)
		if activity.text?
			"text-list"
		elsif activity.text_picture?
			"composite-list"
		elsif activity.picture?
			"img-list"
		end
	end

	def detail_ul_css(activity)
		if activity.text?
			"text-result"
		elsif activity.text_picture?
			"composite-list J-checkbox composite-result"
		elsif activity.picture?
			"img-result"
		end
	end
end