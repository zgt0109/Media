require 'uri'

namespace :baidu do

  task :account => :environment do
    attrs = {
      name: '百度开发者账号',
      app_id: '3BFZG9KBNYj1fVGChtAfRzDe',
      app_secret: '3kIDc7k3FpthYthAF5pTTyfDkYGoQO8p',
    }
    account = ApiApp.where(id: 10003).first_or_create(attrs)
    puts "baidu dev account:#{account.name}, appid:#{account.app_id}, appsecret:#{account.app_secret}"
  end

  task :token => :environment do
    # url = URI::encode("https://openapi.baidu.com/oauth/2.0/token")
    # params = {
    #   grant_type: 'client_credentials',
    #   app_id: '3BFZG9KBNYj1fVGChtAfRzDe',
    #   app_secret: '3kIDc7k3FpthYthAF5pTTyfDkYGoQO8p',
    # }
    # result = RestClient.post(url, params)
    # data = JSON(result)
    # puts data

    ApiApp.baidu.fetch_baidu_token
  end

  task :refresh_token => :environment do
    ApiApp.baidu.fetch_baidu_token(refresh: true)
  end

  # request params: {:access_token=>"24.f313a9619ea3154e2865e7955f89885d.2592000.1418206731.282335-3528270", :app_name=>"mike", :app_logo=>"https://mp.weixin.qq.com/misc/getheadimg?token=1189337400&fakeid=2390790823&r=342502", :app_query=>"mike", :app_url=>"http://m.winwemedia.com/mike", :custom_id=>"19585", :app_desc=>"关注生活服务内容，以及以分享为快乐，分享互联网精彩内容。", :email=>"liangwenke.com@gmail.com", :phone=>""}
  # respone: {"app_id"=>4622582}
  task :create_app => :environment do
    api_app = ApiApp.baidu

    url = URI::encode("https://openapi.baidu.com/rest/2.0/devapi/v1/lightapp/query/create")
    params = {
      access_token: api_app.access_token,
      app_name: 'mike',
      app_logo: 'http://vcl-pictures.qiniucdn.com/Ftkh0D4AOzhrsimGtDqN8tYfzPed',
      app_query: 'mike',
      app_url: 'http://m.winwemedia.com/mike',
      custom_id: '19585',
      app_desc: '关注生活服务内容，以及以分享为快乐，分享互联网精彩内容。',
      email: 'liangwenke.com@gmail.com',
      phone: '',
    }
    puts "request params: #{params}"

    result = RestClient.post(url, params)
    data = JSON(result)
    puts data

    if data['app_id']
      params.delete(:access_token)
      BaiduApp.where(app_id: data['app_id']).first_or_create(params.merge(api_app_id: api_app.id))
    end
  end

  task :status => :environment do
    api_app = ApiApp.baidu
    baidu_app = BaiduApp.where(app_id: '4622582').first

    url = URI::encode("https://openapi.baidu.com/rest/2.0/devapi/v1/lightapp/query/status/get")
    params = {
      access_token: api_app.access_token,
      app_id: baidu_app.app_id,
    }
    result = RestClient.get(url, params: params)
    data = JSON(result)
    puts data

    if data['status']
      baidu_app.update_attributes(status: data['status'])
    end
  end

  task :query => :environment do
    api_app = ApiApp.baidu

    url = URI::encode("https://openapi.baidu.com/rest/2.0/devapi/v1/lightapp/query/isonline")
    params = {
      access_token: api_app.access_token,
      keyword: 'mike',
    }
    result = RestClient.get(url, params: params)
    data = JSON(result)
    puts data

    # if data['status']
    #   api_app.update_attributes(status: data['status'])
    # end
  end

  task :queryinfo => :environment do
    api_app = ApiApp.baidu

    url = URI::encode("https://openapi.baidu.com/rest/2.0/devapi/v1/lightapp/agent/modify/queryinfo")
    params = {
      access_token: api_app.access_token,
      modify_app_id: '4622582',
      query: 'mike',
    }
    result = RestClient.get(url, params: params)
    data = JSON(result)
    puts data
  end

  task :offline => :environment do
    api_app = ApiApp.baidu

    url = URI::encode("https://openapi.baidu.com/rest/2.0/devapi/v1/lightapp/agent/offline")
    params = {
      access_token: api_app.access_token,
      offline_app_id: '4622582',
    }
    result = RestClient.post(url, params)
    data = JSON(result)
    puts data

    # if data['status'] == 1
    #   api_app.update_attributes(status: 7)
    # end
  end

end