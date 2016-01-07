module BaiduMapHelper
	
	#地理位置定位
	#params: (121.488366, 31.248996, 上海市浦东新区郭守敬路498号)
  def baidu_map_address_http(x,y,address)
    "http://api.map.baidu.com/marker?location=#{x},#{y}&title=#{address}&content=#{address}&output=html"
  end

  #经纬度导航
  #params: (23.134521, 113.358803, 23.134521, 113.358803, 门店一, 上海)
  def baidu_map_location_http(lat_s,lng_s,lat_e,lng_e,name_e,city_e)
    "http://api.map.baidu.com/direction?origin=latlng:#{lat_s},#{lng_s}|name:我&destination=latlng:#{lat_e},#{lng_e}|name:#{name_e}&mode=driving&region=#{city_e}&output=html&src=yourCompanyName|yourAppName"
  end

end