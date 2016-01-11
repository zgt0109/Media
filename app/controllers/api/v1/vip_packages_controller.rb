class Api::V1::VipPackagesController < ActionController::Base
	before_filter :cors_set_access_control_headers
	# 会员卡套餐接口，输入参数: wx_mp_user_open_id
  # 成功返回的参数: {id:套餐id,package_name:套餐名称,items_name:服务名称,price:价格,old_price:原价,expiry_num:几个月过期}
  # demo: http://localhost:3000/v1/vip_packages/get_vip_packages_api?mp_user_open_id=gh_db4ac511bbf0
	def get_vip_packages_api
		wx_mp_user = WxMpUser.where(openid: params[:mp_user_open_id]).last
		return render json: { error_code: 1, errmsg: "参数不正确，找不到公众账号" } unless wx_mp_user
		vip_packages = wx_mp_user.supplier.vip_packages.active.latest
		packages = vip_packages.map do |package|
			hash = package.attributes.slice('id', 'price', 'expiry_num', 'supplier_id')
			hash[:items_name] = package.vip_package_items.pluck(:name).join("+")
			hash.merge!(old_price: package.old_price, wxmuid: wx_mp_user.id, package_name: package.name)
		end
		render json: { error_code: 0, vip_packages: packages }.to_json
	end

	# 微客联盟会员卡套餐, 输入参数: city, industry, startNum, pageSize
  def get_vip_packages_life_api
    city, industry, page, per = params.values_at(:city, :industry, :startNum, :pageSize)
    page = page.to_i + 1
    city = WxUser.sanitize(city)
    industry = WxUser.sanitize(industry) if industry.present?

    tag_id = ActiveRecord::Base.connection.execute("select id from tags where name=#{city} limit 1").first.first
    recommended_ids = ActiveRecord::Base.connection.execute("select taggable_id from taggings where context='area' AND tag_id =#{tag_id} ").to_a.flatten.join(",")

    if industry.present?
      industry_wx_mp_user_open_ids = ActiveRecord::Base.connection.execute("select open_id from recommend_wx_mp_users where id in (#{recommended_ids}) AND industry =#{industry} AND has_package = 1  AND enabled =1 ").to_a.flatten
	  else
	  	industry_wx_mp_user_open_ids = ActiveRecord::Base.connection.execute("select open_id from recommend_wx_mp_users where id in (#{recommended_ids}) AND has_package = 1  AND enabled =1 ").to_a.flatten
	  end
	  wx_mp_user_ids = WxMpUser.where(openid: industry_wx_mp_user_open_ids).pluck(:id)
	  vip_packages = VipPackage.where(wx_mp_user_id: wx_mp_user_ids).active.latest.page(page).per(per)
	  packages = vip_packages.map do |package|
			hash = package.attributes.slice('id', 'price', 'expiry_num', 'supplier_id')
			hash[:items_name] = package.vip_package_items.pluck(:name).join("+")
			hash.merge!(old_price: package.old_price, open_id: package.wx_mp_user.openid, package_name: package.name)
		end
    render json: { error_code: 0, vip_packages: packages }.to_json
  end

  private

    def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = '*'
      headers['Access-Control-Allow-Headers'] = '*'
    end

end