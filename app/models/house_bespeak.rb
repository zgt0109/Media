class HouseBespeak < ActiveRecord::Base
  belongs_to :site
  belongs_to :wx_user
  belongs_to :wx_mp_user
  belongs_to :house
  attr_accessor :order_for_time
  after_create :send_igetui_app_message

  enum_attr :status, :in => [
    ['checked',   1, '未看房'],
    ['unchecked', 2, '已看房']
  ]

  def send_igetui_app_message
  	request_url = "#{MERCHANT_APP_HOST}/v1/igetuis/igetui_app_message"
  	attrs = {role: "supplier",role_id: house.supplier_id, token: house.try(:supplier).try(:auth_token),messageable_id: id, messageable_type: "HouseBespeak" ,source: "winwemedia_house", message: "您有一条预约看房的新订单，请注意查看"}
  	#attrs = "#{request_url}?role=supplier&role_id=#{house.supplier_id}&token=#{house.try(:supplier).try(:auth_token)}&messageable_id=#{id}&messageable_type=HouseBespeak&source=winwemedia_wx_plot&message=111"	
  	HTTParty.post(request_url,body:attrs, headers:{'ContentType' => 'application/json'} )
  end 	

end
