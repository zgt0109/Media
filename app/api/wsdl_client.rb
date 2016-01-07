# require 'rubygems' 
require 'savon'
require 'json'
require 'yaml'
require 'open-uri'
require "rexml/document"
require 'mechanize'
include REXML


# include EngineName::SOAP::Savon

class WsdlClient

  def self.vip_card 
    # client = Savon.client(wsdl: 'http://211.143.142.118:8080/wsdl/IeWs')
    # e.g ibianmin,0000000021
    client = Savon.client(wsdl: "http://60.2.64.18:8001/wsdl/IeWs")
    pp client.operations
    response = client.call(:of_interface , message: { v_type: "Find", v_indata: "ibianmin,0000000021", v_outdata: "微信号,会员卡号,积分余额,备注文字" })
    ret = response.body
    pp ret
    # response = client.call(:of_interface) do
    #   message v_type: "New", v_indata: "ibianmin,mlc,男,13761636936", v_outdata: "微信号,会员卡号,积分余额,备注文字"
    #   # convert_request_keys_to :none
    # end
  end

  #获取手机归属地
  def self.get_mobile_info
    client = Savon.client(wsdl: "http://webservice.webxml.com.cn/WebServices/MobileCodeWS.asmx?wsdl")
    client.call(:get_mobile_code_info, message:{mobileCode: "15058109020", userID: ''})
    #client.call(:get_database_info)
  end

  def self.get_qq_online_status
    client = Savon.client(wsdl: "http://webservice.webxml.com.cn/webservices/qqOnlineWebService.asmx?wsdl")
    client.call(:qq_check_online, message:{qqCode: '451618995'})
  end

  #根据出发地和目的地获得航班时刻表
  def self.get_domestic_airlines_time from, to
    client = Savon.client(wsdl: 'http://www.webxml.com.cn/webservices/DomesticAirline.asmx?wsdl')
    response = client.call(:get_domestic_airlines_time , message: { startCity: from, lastCity: to, theDate: "", userID:"" })
    # startCity = 出发城市（中文城市名称或缩写、空则默认：上海）；lastCity = 抵达城市（中文城市名称或缩写、空则默认：北京）
    ret = response.body.to_json
  end

  #根据航班编号查找信息
  def self.get_airline_info_by_no no
    html=open("http://flight.qunar.com/status/fquery.jsp?flightCode=#{no.upcase}").read
    doc=Nokogiri::HTML(html)
    message = ""
    doc.css('.state_detail dt').each do |link|
      message += link.content
      message += "\n"
    end

    doc.css('.state_detail .sd_1').each do |link|  
      message += link.content  #起降机场
      message += "\n"
    end  
    doc.css('.state_detail .sd_4').each do |link|  
      message += link.content  #机型
      message += "\n"
    end  
    doc.css('.state_detail .sd_4:nth-child(2)').each do |link|  
      message += link.content  #餐食
      message += "\n"
    end  
    message += doc.css('.state_detail .sd_2')[0].content
    message += "\n"

    doc.css('.state_detail .sd_5').each do |link|  
      message += link.content  #飞行距离和时间
      message += "\n"
    end  
    message += doc.css('.state_detail .sd_2')[1].content.to_s.slice(1,doc.css('.state_detail .sd_2')[1].content.to_s.length) #预计时间  
    message += "\n"
    message += doc.css(".state_detail .sd_2")[2].content

    return message
  end

  #时差查询
  # def self.time city
  #   url = "http://time.123cha.com/?q=#{city}"
  #   agent = Mechanize.new
  #   page = agent.get(url)
  #   ret =  agent.page.link_with(:text => "查看更详细资料").click
  #   ret_page = ret.at("#timedetail")
  #   current_time = ret_page.css(".c2")[0].content.squeeze(" ").strip
  #   time_area = ret_page.css(".c2")[1].css("ul li")[0].content.squeeze(" ").strip

  #   message = "#{city} \n 当前时间: #{current_time} \n 所处时区: #{time_area}"
  #   puts message
  #   return message
  # end

  #列车号查询信息
  def self.get_detail_info_by_train_code no
    html = open("http://search.huochepiao.com/chaxun/resultc.asp?txtCheCi=#{no.upcase}").read
    html.force_encoding("gbk")
    html.encode!("utf-8")
    doc = Nokogiri::HTML(html)
    message = ""
    top_table = doc.css("table")[6]
    puts top_table.class
    train_no = top_table.css('tr td')[2].content #车次
    time = top_table.css('tr td')[4].content #时间
    dist = top_table.css('tr')[3].css('td')[3].content#里程

    price_html = open("http://www.huochepiao.net/checi_#{no.upcase}").read
    price_html.force_encoding("gbk")
    price_html.encode!("utf-8")
    price_doc = Nokogiri::HTML(price_html)
    price_table = price_doc.css("table")[4].css("table")[0]
  
    yz_price = price_table.css('tr')[1].css('td')[5].content      #硬座
    rz_price = price_table.css('tr')[1].css('td')[7].content      #软座
    yw_price = price_table.css('tr')[2].css('td')[5].content      #硬卧
    rw_price = top_table.css('tr')[3].css('td')[5].content        #软卧
                                      
    message += "#{train_no}\n"
    message += "时间: #{time}\n"
    message += "里程: #{dist}\n"   
    message += "硬座: #{yz_price}\n"
    message += "软座: #{rz_price}\n"
    message += "硬卧: #{yw_price}\n"
    message += "软卧: #{rw_price}\n"

    #站台列表
    message += "车站\t 到站 - 离站 \n"
    train_table = price_doc.css("table")[4].css("table")[1].css('tr:not(:first-child)')
  
    train_table.each do |row|
      message += "#{row.css('td')[1].content}.#{row.css('td')[2].content}\t#{row.css('td')[3].content}\t#{row.css('td')[4].content}\n"
    end

    return message
  end

  #列车站头查询信息
  def self.get_detail_info_by_train_citys from, to
    from = from.encode('gb2312')
    to = to.encode('gb2312')
    url = "http://search.huochepiao.com/chaxun/result.asp?txtChuFa=#{from}&txtDaoDa=#{to}"
    url = URI::encode(url)
    html = open(url).read
    html.force_encoding("gbk")
    html.encode!("utf-8")
    doc = Nokogiri::HTML(html)
    content_table = doc.css('table')[9]
    if content_table 
      message = "为您查到以下火车信息(如果需要查询具体火车信息请输入\"火车XXX\", 比如\"火车T109\"):\n"
      content_table.css('tr').each do |row|
        type = ''
        row.css('td')[2].css('img').each do |a|
          type = a['title']
        end
        message += "#{row.css('td')[0].content} (#{type}) \n"
        message += "#{row.css('td')[2].content} - #{row.css('td')[4].content}\n"
        message += "时长: #{row.css('td')[6].content}\n"
        message += "时间: #{row.css('td')[3].content} - #{row.css('td')[5].content}\n"
        message += "价格: 一等软座: ¥#{row.css('td')[9].content}, 二等软座: ¥#{row.css('td')[8].content}\n"
        message += "\n"
        break if message.length > 300
      end
    else
      message = "您要查找的火车不存在"
    end
    return message
  end

  def self.wiki keyword
    url = "http://zh.wikipedia.org/wiki/#{keyword}"
    url = URI::encode(url)
    puts url
    html = open(url).read
    doc = Nokogiri::HTML(html)
    content = doc.css('#mw-content-text>p')[0].content
    if content.empty?
      content = doc.css('#mw-content-text>p')[1].content
    end
    return content
  end

  def self.time keyword
    url = "http://time.123cha.com"
    agent = Mechanize.new
    page = agent.get(url)
    target_div = page.at("#timebox")
    li_array = target_div.css("li")
    ret_message = "";
    li_array.each do |li|
      if li.to_s.include?(keyword)
        a_link = li.css("a")[0]
        link = a_link.attr('href')
        one_agent = Mechanize.new
        one_detail = one_agent.get("#{url}#{link}")
        puts one_detail
        ret_page = one_detail.at("#timedetail")
        current_time = ret_page.css(".c2")[0].content.squeeze(" ").strip
        time_area = ret_page.css(".c2")[1].css("ul li")[0].content.squeeze(" ").strip
        city = one_detail.at(".morebox").css("h2")[0].content
        message = "#{city} \n当前时间: #{current_time} \n所处时区: #{time_area} \n"
        puts message
        ret_message += message
      end
    end
    return ret_message
  end

end

# WsdlClient.vip_card
# WsdlClient.time "纽约"
# WsdlClient.wiki "进击的巨人"

# WsdlClient.get_domestic_airlines_time "上海", "北京"

#p "汉字" #"\u6C49\u5B57"