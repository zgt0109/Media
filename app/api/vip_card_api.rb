require 'savon'
require 'json'
require 'yaml'
require 'open-uri'
require "rexml/document"
require 'mechanize'
include REXML

class VipCardApi

  attr_accessor :error_message

  CONFIG_OPTOINS = { 
                    10507 => 'http://60.2.64.18:8001/wsdl/IeWs'
                   }

  def initialize(wsdl)
    @client = Savon.client(wsdl: wsdl)
  rescue => e
    error_message = e.message
  end

  # 返回结果例子: "ibianmin,0000000021,16.43,成功"
  def find_vip_card wx_name, vip_no
    return unless @client
    response = @client.call(:of_interface , message: { v_type: "Find", v_indata: "#{wx_name},#{vip_no}", v_outdata: "微信号,会员卡号,积分余额,备注文字" })
    ret = response.body.to_json
    json = JSON ret
    result = json['of_interface_response']['return']
    out_data = json['of_interface_response']['v_outdata']

    { result: result.to_i, data: out_data }
  rescue => e
    error_message = e.message
    { result: 0, data: error_message }
  end

  # 返回结果例子 "abc, 0000000041,0.00,成功"
  def new_vip_card wx_name, user_name, sex, number
    return unless @client

    data = [wx_name, user_name, sex, number].join(',')

    puts "data ************* #{data}"
    WinwemediaLog::Base.logger('user_api', "vip card data: #{data}")

    response = @client.call(:of_interface , message: { v_type: "New", v_indata: data, v_outdata: "微信号,会员卡号,积分余额,备注文字" })
    puts "response: #{response}"

    ret = response.body.to_json
    json = JSON ret

    result = json['of_interface_response']['return']
    out_data = json['of_interface_response']['v_outdata']

    { result: result.to_i, data: out_data }
  rescue => e
    error_message = e.message
    { result: 0, data: error_message }
  end

end

# vca = VipCardApi.new "http://60.2.64.18:8001/wsdl/IeWs"
# puts vca.find_vip_card "abc","888800000000000196"
# puts vca.new_vip_card("abc", "mmm", "女", "5938383838")
#                   微信号,姓名,  性别,   电话号'
#{:result=>1, :data=>"abc,888800000000000196,0.00,申请会员卡成功"}