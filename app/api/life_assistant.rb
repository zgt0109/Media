require 'open-uri'
require 'json'
require 'savon'
require 'net/http'
require 'uri'
require_relative './wsdl_client'

class LifeAssistant

  def self.handle_keyword(keyword)
    k = keyword.slice(2, keyword.length)
    case keyword
    when /^翻译/ then translate(k)
    when /^股票/ then stock(k)
    when /^百科/ then wiki(k)
    when /^快递/ then express(k)
    when /^时差/ then time(k)
    when /^天气/ then weather(k.sub(/^@/, ''))
    when /^汇率/ then currency(*k.split(' ')[0, 2])
    when /^火车/ then train_or_train_no(k)
    when /^航班/ then air_or_air_no(k)
    end
  end

  def self.train_or_train_no(keyword)
    return train_by_no(keyword) if keyword =~/^[a-zA-Z][a-zA-Z0-9_]*$/  #查编号
    cities = keyword.split("到")
    train(cities[0], cities[1])
  end

  def self.air_or_air_no(keyword)
    return air_by_no(keyword) if keyword =~ /^[a-zA-Z][a-zA-Z0-9_]*$/
    cities = keyword.split("到")
    air(cities[0], cities[1])
  end

  # 返回字符串 e.g. "n. 吻；轻拂"
  def self.translate keyword
    url = "http://fanyi.youdao.com/openapi.do?keyfrom=winwemedia&key=445408961&type=data&doctype=json&version=1.1&q=#{keyword}"
    ret = HttpOpen.get(url, HttpOpen::DEFAULT_TIMEOUT)
    if ret["error"]
      ret["error"].to_s
    else
      body = JSON.parse(ret['body'])
      if body['basic']
        body['basic']['explains'][0]
      else
        "翻译问题，如翻译hello"
      end
    end
  end

  # 返回字符串 e.g. "股票名称:兰花科创\n当前价格:9.48\n今日开盘价:9.39\n昨日收盘价:9.43\n今日最高价:9.60\n今日最低价:9.36"
  def self.stock keyword
    url = "http://hq.sinajs.cn/list=sh#{keyword}"
    request = HttpOpen.get(url, HttpOpen::DEFAULT_TIMEOUT)
    if request["error"]
      content = request["error"].to_s
    else      
      ret = request["body"].encode("UTF-8", "GBK")
      index = ret.index("=")
      ret = ret[index+2, ret.length]
      arrays = ret.split(',')
      if arrays[0].empty? || arrays[0].start_with?("\"")
        content = "股票编号不存在"
      else
        content = "股票名称:#{arrays[0].force_encoding('UTF-8')}
  当前价格:#{arrays[3]}
  今日开盘价:#{arrays[1]}
  昨日收盘价:#{arrays[2]}
  今日最高价:#{arrays[4]}
  今日最低价:#{arrays[5]}"
      end
    end
    return content
  end
  
  def self.music keyword
    hot_song_names = %W(夜空中最亮的星 追梦赤子心 江南STYLE 一起摇摆 董小姐 最炫民族风 光辉岁月 挪威的森林)
    if keyword.empty?
      keyword = hot_song_names.sample
    end
    url = "http://api2.sinaapp.com/search/music/?appkey=0020130430&appsecert=fa6095e1133d28ad&reqtype=music&keyword=#{keyword}"
#    url = URI::encode(url)
#    data = open(url).read
#    ret = JSON.parse data
    request = HttpOpen.get(url, HttpOpen::DEFAULT_TIMEOUT)
    if request["error"]
      title = request["error"].to_s
      music_url = "http://shiting.chaishouji.com/error.mp3"
      hq_music_url = music_url
    else
      ret = JSON.parse(request["body"])
      title = ret['music']['title']
      music_url = ret['music']['musicurl']
      hq_music_url = ret['music']['hqmusicurl']
    end
    xml = "<Music>
         <Title><![CDATA[#{title}]]></Title>
         <Description><![CDATA[ ]]></Description>
         <MusicUrl><![CDATA[#{music_url}]]></MusicUrl>
         <HQMusicUrl><![CDATA[#{hq_music_url}]]></HQMusicUrl>
         </Music>"
  end

  def self.weather keyword
    city_name = URI::encode("#{keyword}天气")
    # # uri = "http://api.uihoo.com/weather/weather.http.php?key=#{keyword}&format=json"
    # uri = "http://php.weather.sina.com.cn/xml.php?city=#{city_name}&password=DJOYnieT8234jlsK&day=0#tc_qz_original=584052805"
    # request = HttpOpen.get(uri, HttpOpen::DEFAULT_TIMEOUT)
    # message = "#{keyword}天气预报(实时)\n"
    # if request["error"]
    #   message += request["error"].to_s
    # else
    #   array = JSON.parse(request["body"])
    #   message+= "[#{array["now"]["city"]}] 天气情况:\n"
    #   message+= "温度: #{array["now"]["temp"]}, 风向: #{array["now"]["WD"]}, 风速: #{ array["now"]["WS"]}\n"
    #   message+= "今天(#{array["forecast"]["ate_y"]}) #{array["forecast"]["temp1"]} #{array["forecast"]["weather1"]}\n"
    #   message+= "明天 #{array["forecast"]["temp2"]} #{array["forecast"]["weather2"]}\n"
    #   message+= "后天 #{array["forecast"]["temp3"]} #{array["forecast"]["weather3"]}\n"
    #   message+= "紫外线指数 #{array["forecast"]["index_uv"]}\n"
    #   message+= "洗车指数 #{array["forecast"]["index_xc"]}\n"
    #   message+= "旅游指数 #{array["forecast"]["index_tr"]}\n"
    #   message+= "舒适度指数 #{array["forecast"]["index_co"]}\n"
    #   message+= "运动指数 #{array["forecast"]["index_cl"]}\n"
    #   message+= "晾晒指数 #{array["forecast"]["index_ls"]}\n"
    #   message+= "过敏指数 #{array["forecast"]["index_ag"]}\n"
    #   message+= "穿衣指数 #{array["forecast"]["index"]}\n"
    #   message+= "穿衣建议 #{array["forecast"]["index_d"]}\n"
    # end
    # return message
    return "<a href=\"http://www.baidu.com/#wd=#{city_name}\">点击查看#{keyword}天气</a>"
  end

  def self.air from, to
    client = Savon.client(wsdl: 'http://www.webxml.com.cn/webservices/DomesticAirline.asmx?wsdl')
    response = client.call(:get_domestic_airlines_time , message: { startCity: from, lastCity: to, theDate: "", userID:"" })
    ret = WsdlClient.get_domestic_airlines_time from, to
    obj = JSON.parse(ret)
    rets = obj['get_domestic_airlines_time_response']['get_domestic_airlines_time_result']['diffgram']['airlines']['airlines_time']
   
    message = "为您查到以下航班(如果需要查询具体航班信息请输入\"航班 XXX\", 比如\"航班ZH1601\"):\n"
    rets.each do |r|
      message += "\n"
      message += "#{r['start_time']} - #{r['arrive_time']}"
      message += "\n"
      message += "#{r['airline_code']} \t #{r['company']}"
      message += "\n"
      message += "#{r['start_drome']} - #{r['arrive_drome']}"
      message += "\n"
      break if message.length > 300
    end
    return message
  end

  def self.air_by_no no
    WsdlClient.get_airline_info_by_no no
  end

  def self.train_by_no no
    WsdlClient.get_detail_info_by_train_code no
  end

  def self.train from, to 
    WsdlClient.get_detail_info_by_train_citys from, to
  end

  def self.wiki keyword
    WsdlClient.wiki keyword
  end

  def self.express keyword
    url = "http://www.kuaidi100.com/autonumber/auto?num=#{keyword}" 
    url = URI::encode(url)
    data = open(url).read
    ret = JSON.parse data
    type = ret[0]['comCode']
    query = "http://www.kuaidi100.com/query?type=#{type}&postid=#{keyword}&id=1&valicode=&temp=0.9590612647589296"
    query = URI::encode(query)
    content = open(query).read
    json = JSON content
    result = json['data']
    message = ''
    result.each do |r|
      message += "#{r['time']} --- #{r['context']}\n"
    end
    return message
  end

  def self.currency from, to
    url = "http://api.uihoo.com/currency/currency.http.php?from=#{from}&to=#{to}&format=json"

    request = HttpOpen.get(url, HttpOpen::DEFAULT_TIMEOUT)
    if request["error"]
      content = request["error"]
    else
      ret = JSON.parse(request["body"])
      now = ret['now']
      date = ret['date']
      time = ret['time']
      buy = ret['buy']
      sale = ret['sale']
      from_cn = ret['from_cn']
      to_cn = ret['to_cn']
      content = "#{from_cn}-#{to_cn} \n汇率比: #{now} \n"
      content += "时间: #{date} #{time}\n"
      content += "买入: #{buy}\n"
      content += "卖出: #{sale}\n"
    end
    return content
  end

  def self.time city
    WsdlClient.time city
  end

end

# {
# now: "0.1642",
# date: "11-8-2013",
# time: "8:39pm",
# buy: "0.1642",
# sale: "0.1642",
# from_cn: "人民币",
# to_cn: "美元"
# }

# LifeAssistant.currency('cny', 'usd')
# LifeAssistant.express
# LifeAssistant.air "上海", "北京"
# LifeAssistant.stock "601318"
# LifeAssistant.music "安静"
# LifeAssistant.test
# LifeAssistant.weather "上海"