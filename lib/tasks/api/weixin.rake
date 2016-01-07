require 'uri'

namespace :weixin do
  task :get_token do
    url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=wxd8d1b78afa400b0d&secret=b60797c0bfc807906390d8f7278d70c9"
    url = URI::encode(url)
    result = RestClient.get(url)
    info = JSON(result)
    puts info
  end

  task :create_menu do
    menus = '{
      "button":[
       {
          "name":"互动推广",
          "sub_button":[
           {
              "type":"click",
              "name":"刮刮乐",
              "key":"ggl"
           },
           {
              "type":"click",
              "name":"大转盘",
              "key":"dzp"
           }]
        },
       {
            "type":"click",
            "name":"会员卡",
            "key":"card"
        },
        {
             "type":"click",
             "name":"微官网",
             "key":"website"
        }],
      }'

    access_token = 'xrR4AD_MIwIf0VXOVYiu0qSl53j6T22Hp9LElMY-nMwcKLmfvWEzmPNGsxj0DjKv3AN5lbGTZXYkHQlA2ZLxqIk_SmLk9rlnyFBKqUHgtYbpEBPqOKvdcfpfY057X-6qMc2I3wSfABRedFF2xZi6MQ'
    result = RestClient.post("https://api.weixin.qq.com/cgi-bin/menu/create?access_token=#{access_token}", menus)

    info = JSON(result)
    puts info
  end

  task :get_menu do
    result = RestClient.get("https://api.weixin.qq.com/cgi-bin/menu/get?access_token=xrR4AD_MIwIf0VXOVYiu0qSl53j6T22Hp9LElMY-nMwcKLmfvWEzmPNGsxj0DjKv3AN5lbGTZXYkHQlA2ZLxqIk_SmLk9rlnyFBKqUHgtYbpEBPqOKvdcfpfY057X-6qMc2I3wSfABRedFF2xZi6MQ")
    info = JSON(result)
    puts info
  end

  task :delete_menu do
    result = RestClient.get("https://api.weixin.qq.com/cgi-bin/menu/delete?access_token=xrR4AD_MIwIf0VXOVYiu0qSl53j6T22Hp9LElMY-nMwcKLmfvWEzmPNGsxj0DjKv3AN5lbGTZXYkHQlA2ZLxqIk_SmLk9rlnyFBKqUHgtYbpEBPqOKvdcfpfY057X-6qMc2I3wSfABRedFF2xZi6MQ")
    info = JSON(result)
    puts info
  end

  # http://api.map.baidu.com/lbsapi/cloud/ip-location-api.htm
  # http://api.map.baidu.com/location/ip?ak=F454f8a5efe5e577997931cc01de3974&ip=202.198.16.3&coor=bd09ll
  task :get_ip do
    result = RestClient.get("http://api.map.baidu.com/location/ip?ak=9c72e3ee80443243eb9d61bebeed1735&coor=bd09ll")
    info = JSON(result)
    puts info['content']['address_detail']
  end

  # http://developer.baidu.com/map/webservice-geocoding.htm
  task :get_location do
    params = { address: '杨浦区国年路25弄5号', output: 'json', ak: '9c72e3ee80443243eb9d61bebeed1735'}
    result = RestClient.get("http://api.map.baidu.com/geocoder/v2/", params: params)
    data = JSON(result)
    # puts data
    puts data['result']['location']
  end
  
  task :print do
    now = DateTime.now.to_i
    
    content = "<xml>
    <ToUserName><![CDATA[gh_9a727dfba31f]]></ToUserName>
    <FromUserName><![CDATA[op5KAjkRE0LC8ZXVEYAVyxCS-ojs]]></FromUserName>
    <CreateTime>#{now}</CreateTime>
    <MsgType><![CDATA[image]]></MsgType>
    <PicUrl><![CDATA[http://test.winwemedia.com/uploads/website_picture/pic/377b8cb0b96760d78184e9a6253aa911.jpg]]></PicUrl>
    <MsgId>1234567890123456</MsgId>
    </xml>
    "
    result = RestClient.post("http://inleader.weixinprint.com/weixin?publicUserId=306", content, :content_type => :xml, :accept => :xml)
    # data = JSON(result)
    
    # xml = ''
    # Nokogiri::XML.parse(result).css('xml').children.each do |element|
    #   xml[element.name] = element.text
    #   #logger.info "element #{element.name.to_sym} : #{element.text}"
    # end
    
    puts result
    # puts data['result']['location']
  end
  
  task :print_text do
    now = DateTime.now.to_i
    
    content = "<xml>
                      <ToUserName><![CDATA[gh_31f2ef98fbc1]]></ToUserName>
                      <FromUserName><![CDATA[op5KAjmcsmH9WeXGpytdXuhx6DVc]]></FromUserName>
                      <CreateTime>1390812963</CreateTime>
                      <MsgType><![CDATA[text]]></MsgType>
                      <Content><![CDATA[1111111]]></Content>
                      <MsgId>5973496191137869893</MsgId>
                      </xml>
    "
    result = RestClient.post("http://inleader2.weixinprint.com/weixin?publicUserId=79", content, :content_type => :xml, :accept => :xml)
    # data = JSON(result)
    
    # xml = ''
    # Nokogiri::XML.parse(result).css('xml').children.each do |element|
    #   xml[element.name] = element.text
    #   #logger.info "element #{element.name.to_sym} : #{element.text}"
    # end
    
    puts result
    # puts data['result']['location']
  end
  
  task :get_auth do
    redirect_uri = URI::encode('http%3A%2F%2Ftesting.m.winwemedia.com%2F/about')
    puts "redirect_uri: #{redirect_uri}"
    url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=wx818e511f332984b9&redirect_uri=#{redirect_uri}&response_type=code&scope=snsapi_base&state=testing#wechat_redirect"
    puts "url: #{url}"
    result = RestClient.get(url)
    puts result.body
  end
  
  task :kf do
    @echostr = "<xml>
    <ToUserName><![CDATA[oblD8jkTeEiDLMsSDj3899dOnOks]]></ToUserName>
    <FromUserName><![CDATA[gh_f5694826577d]]></FromUserName>
    <CreateTime>1399701108</CreateTime>
    <MsgType><![CDATA[transfer_customer_service]]></MsgType>
    </xml>"
    
    result = RestClient.post("http://staging.winwemedia.com/api/service?id=MTAwMDE=", @echostr)
    # data = JSON(result)
    
    # xml = ''
    # Nokogiri::XML.parse(result).css('xml').children.each do |element|
    #   xml[element.name] = element.text
    #   #logger.info "element #{element.name.to_sym} : #{element.text}"
    # end
    
    puts result
    # puts data['result']['location']
  end
  
end