class HouseBespeak < ActiveRecord::Base
  belongs_to :site
  belongs_to :user
  belongs_to :house
  attr_accessor :order_for_time
  # after_create :send_igetui_app_message

  enum_attr :status, :in => [
    ['checked',   1, '未看房'],
    ['unchecked', 2, '已看房']
  ]

  def send_igetui_app_message
  	request_url = "#{MERCHANT_APP_HOST}/v1/igetuis/igetui_app_message"
  	attrs = {role: "site",role_id: house.site_id, token: house.site.account.try(:token),messageable_id: id, messageable_type: "HouseBespeak" ,source: "house", message: "您有一条预约看房的新订单，请注意查看"}
  	#attrs = "#{request_url}?role=site&role_id=#{house.site_id}&token=#{house.try(:site).try(:auth_token)}&messageable_id=#{id}&messageable_type=HouseBespeak&source=wx_plot&message=111"
  	HTTParty.post(request_url,body:attrs, headers:{'ContentType' => 'application/json'} )
  end

end
