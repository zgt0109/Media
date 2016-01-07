class BaiduMapService
  class << self
    def respond_location(from_user_name, mp_user, keyword)
      to_user_name = mp_user.uid
      wx_user = mp_user.wx_users.where(uid: from_user_name).first

      location_missed_or_expired = wx_user.location_updated_at.blank? || (Time.now - wx_user.location_updated_at >= 300)
      return require_location_info(from_user_name, to_user_name) if location_missed_or_expired

      params = {radius: 2000, location: wx_user.axis, scope: 2, query: keyword, output: 'json', ak: '9c72e3ee80443243eb9d61bebeed1735'}
      Rails.logger.info "********************baidu map api params: #{params}"

      request = RestClient.get('http://api.map.baidu.com/place/v2/search', params: params)
      response = JSON.parse(request)
      results = response['results']

      return send_nearby(from_user_name, to_user_name) if results.count == 0

      results = results.take(8)
      results = results.sort_by { |result| result['detail_info']['distance'] }
      items = results.map do |result|
        {
            title:       "#{result['name']}, 地址: #{result['address']}, 电话: #{result['telephone']}, 距离: #{result['detail_info']['distance']}米",
            description: "#{result['name']}, 地址: #{result['address']}, 电话: #{result['telephone']}, 距离: #{result['detail_info']['distance']}米",
            pic_url:     BaiduMapService.static_map_url(result['location']['lat'], result['location']['lng']),
            url:         BaiduMapService.inline_map(result['location']['lat'], result['location']['lng'], result['name'], result['address'])
        }
      end

      if results.count > 1
        items << {
            title:       keyword,
            description: "一共找到#{items.count}个结果",
            pic_url:     BaiduMapService.static_map_url(wx_user.location_x, wx_user.location_y),
            url:         BaiduMapService.inline_map(wx_user.location_x, wx_user.location_y, '您所处位置', wx_user.location_label)
        }
      end

      Weixin.respond_news(from_user_name, to_user_name, items)
    end


    def static_map_url(location_x, location_y)
      "http://api.map.baidu.com/staticimage?center=#{location_y},#{location_x}&markers=#{location_y},#{location_x}&width=300&height=200&zoom=16"
    end

    def send_nearby(from_user_name, to_user_name)
      Weixin.respond_text(from_user_name, to_user_name, '请发送附近学校,附近银行,附近医院,附近小吃,附近美食,附近酒吧,附近咖啡厅...')
    end

    def require_location_info(from_user_name, to_user_name)
      Weixin.respond_text(from_user_name, to_user_name, '您的地理位置还没有记录或者已过期，请先发送位置信息(点击＋号可以看到发送位置的按钮),再发送附近学校,附近银行,附近医院,附近小吃,附近美食,附近酒吧,附近咖啡厅...')
    end

    def inline_map(lat, lng, name, address)
      URI.encode("#{MOBILE_DOMAIN}/api/map_url?lat=#{lat}&lng=#{lng}&name=#{name}&address=#{address}")
    end

  end
end