require 'uri'

namespace :bqq do

  task :token do

    url = "https://api.b.qq.com/crm/token?appid=1300000111&secret=XCA82knTR1AP0YT8"
    url = URI::encode(url)
    result = RestClient.get(url)
    info = JSON(result)
    puts info
  end

  task :privileges do
    privileges = {
      privilege: [
        {
          id: 1001,
          title: '生活小助手',
          desc: ''
        },
        {
          id: 1002,
          title: '休闲小游戏',
          desc: ''
        },
        {
          id: 2001,
          title: '电子优惠券',
          desc: ''
        }
      ]
    }

    access_token = 'f78fb90eee912328b6570a5f9bbb9b2b'
    result = RestClient.post("https://api.b.qq.com/crm/partner/privilege?access_token=#{access_token}", params: privileges)
    puts result.body
  end

  task :reply do
    # reply = "{
    #     \"fromuser\": \"4000000097\",
    #     \"touser\": \"OPENID\",
    #     \"keywords\": \"keywords\",
    #     \"msgtype\": \"text\",
    #     \"text\": {
    #       \"content\": \"hello world\"
    #     }
    # }"

    reply = "{
      \"fromuser\": \"4000000097\",
      \"touser\":\"OPENID\",
      \"keywords\":\"test001\",
      \"msgtype\":\"news\",
      \"news\":{
        \"articles\": [
           {
             \"title\":\"Happy Day\",
             \"description\":\"Is Really A Happy Day\",
             \"url\":\"URL\",
             \"picurl\":\"PIC_URL\"
           },
           {
             \"title\":\"Happy Day\",
             \"description\":\"Is Really A Happy Day\",
             \"url\":\"URL\",
             \"picurl\":\"PIC_URL\"
           }
         ]
      }
    }"

    access_token = '662071bcb996f7617330c288d2f1e690'
    url = URI::encode("https://api.b.qq.com/crm/partner/autoreply?access_token=#{access_token}")
    result = RestClient.post(url, reply)
    # info = JSON(result)
    puts result
  end

end