class Api::V1::QrcodeChannelsController < ActionController::Base
	before_filter :cors_set_access_control_headers
	# 二维码推广接口，输入参数: wx_user_open_id, column_name, amount
  # 成功返回: { errcode: 0, errmsg: "ok" }
  # demo: http://localhost:3000/v1/qrcode_channels/qrcode_user_amount_api?wx_user_open_id=oZmj5jinqjCrKZJAUUI0fnJ7bcqU&column_name=hotel_amount&amount=1&payment_type="支付宝"
	def qrcode_user_amount_api
		wx_user = WxUser.where(openid: params[:wx_user_open_id]).last
		return render json: { errcode: 1, errmsg: "参数不正确，找不到公众账号" } unless wx_user
		wx_user.qrcode_user_amount(params[:column_name],params[:amount]) unless params[:payment_type] == "余额支付"
		render json: { errcode: 0, errmsg: "ok" }.to_json
	end

  private

    def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = '*'
      headers['Access-Control-Allow-Headers'] = '*'
    end
	
end