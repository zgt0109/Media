class WxUserData


  METHODS = ["getupstreammsgmonth", "getupstreammsg", "getupstreammsghour",
    "getupstreammsgweek", "getupstreammsgdist", "getupstreammsgdistweek",
    "getupstreammsgdistmonth", "getusersummary", "getusercumulate","getarticlesummary",
  "getarticletotal","getuserread","getuserreadhour","getusershare","getusersharehour"]

  class << self
    METHODS.each do |method_name|

      define_method(method_name) do |options={}|
        return {} if options[:openid].nil?

        current_wx_mp_user=WxMpUser.find_by_openid(options[:openid])

        url ="https://api.weixin.qq.com/datacube/#{method_name}?access_token=#{current_wx_mp_user.wx_access_token}"

        parameters = {:begin_date => options[:begin_date], :end_date => options[:end_date]}.to_json

        JSON.parse(RestClient.post(url, parameters))
      end
    end




end
