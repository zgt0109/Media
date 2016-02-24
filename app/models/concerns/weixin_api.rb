module Concerns::WeixinApi

  def wx_user_list( options={} )
    url = "https://api.weixin.qq.com/cgi-bin/user/get?access_token=#{self.wx_access_token}&next_openid=#{options[:next_openid]}"
    get_request(url)["data"]["openid"]
  end

  def wx_user_info
    wx_user_list.each do |l|
      @wxuser=WxUser.new(wx_mp_user_id: self.id)
      url = "https://api.weixin.qq.com/cgi-bin/user/info?access_token=#{self.wx_access_token}&openid=#{l}&lang=zh_CN"
      parameters = JSON.parse(get_request(url))
      @wxuser.update_attributes(parameters)
      @wxuser.save
    end
  end

  def wx_user_group_list
    #code
    url = "https://api.weixin.qq.com/cgi-bin/groups/get?access_token=#{self.wx_access_token}"
    groups = get_request(url)["groups"]
  end

  def create_user_group( name )
    url = "https://api.weixin.qq.com/cgi-bin/groups/create?access_token=#{self.wx_access_token}"
    parameters = {:group => {:name => name}}.to_json
    post_request(url,parameters)
  end

  def change_group_name( options={} )
    parameters = {:group =>{:id =>options[:id],:name =>options[:name]}}.to_json
    url = "https://api.weixin.qq.com/cgi-bin/groups/update?access_token=#{self.wx_access_token}"
    post_request(url,parameters)

  end

  def delete_wx_group( id )
    url="https://api.weixin.qq.com/cgi-bin/groups/delete?access_token=#{self.wx_access_token}"
    parameters = {:group=>{:id=>id}}.to_json
    post_request(url,parameters)
  end

  def move_wx_user_list( options={} )
    # options = {:openid_list => ["oMtqxt1LlPdU-zdC3n4DhL6mEEDU"],:to_groupid =>101}
    url = "https://api.weixin.qq.com/cgi-bin/groups/members/batchupdate?access_token=#{self.wx_access_token}"
    parameters = {:openid_list => options[:openid_list],:to_groupid => options[:to_groupid]}.to_json
    post_request(url,parameters)
  end

  def move_wx_user(options={})
    # options = {:openid => "oMtqxt1LlPdU-zdC3n4DhL6mEEDU",:to_groupid =>100}
    url = "https://api.weixin.qq.com/cgi-bin/groups/members/update?access_token=#{self.wx_access_token}"
    parameters = {:openid =>options[:openid],:to_groupid => options[:to_groupid]}.to_json
    post_request(url,parameters)
  end

  def get_wx_user_id( openid )
    #code
    url = "https://api.weixin.qq.com/cgi-bin/groups/getid?access_token=#{self.wx_access_token}"
    parameters = {:openid=> openid}.to_json
    post_request(url,parameters)["groupid"].to_i
  end

  def set_remark( options = {} )
    url = "https://api.weixin.qq.com/cgi-bin/user/info/updateremark?access_token=#{self.wx_access_token}"
    parameters = {:openid =>options[:openid] ,:remark =>options[:remark]}.to_json
    post_request(url,parameters)
    WxUser.find_by_openid(options[:openid]).update_attributes(remark:options[:remark])
  end

  def media_upload( options = {})
    url = "https://api.weixin.qq.com/cgi-bin/media/upload?access_token=#{self.wx_access_token}&type=#{options[:type]}"
    parameters = {:media=>File.new("/Users/icepoint1999/Desktop/company.jpg")}
    post_request(url,parameters)
  end

  def media_upload_news( options = {} )
    # options={:title => "2",:thumb_media_id =>"AS_OnDp_LpWAyrON2SHkawv_3ZJoxGTkigZymwpRQ-WE9H5aSCMfFPRbkyiuMAEX",:author =>"asd",
    # :digest =>"12",:show_cover_pic=>"1",:content=>"asdasdasd <img src='http://img.baidu.com/img/iknow/sula201601/beijingmaohou270.jpg?t=1455621428' alt=''>",:content_source_url=>"asdasd"  }

    url = "https://api.weixin.qq.com/cgi-bin/media/uploadnews?access_token=#{self.wx_access_token}"
    parameters = {:articles=>[{
      title: options[:title],
      thumb_media_id: options[:thumb_media_id],
      author: options[:author],
      digest: options[:digest],
      show_cover_pic: options[:show_cover_pic],
      content: options[:content],
      content_source_url: options[:source_url]
    }]}.to_json

    post_request(url,parameters)

  end

  def material_add_news( options = {} )
    url ="https://api.weixin.qq.com/cgi-bin/material/add_news?access_token=#{self.wx_access_token}"
    params ={
      articles: [{
        title: options[:title],
        thumb_media_id: options[:thumb_media_id],
        author: options[:author],
        digest: options[:digest],
        show_cover_pic: options[:show_cover_pic],
        content: options[:content],
        content_source_url: options[:source_url]
      }]
    }.to_json

    post_request(url,params)
  end

  def material_add_media( options = {} )
    url = "https://api.weixin.qq.com/cgi-bin/material/add_material?access_token=#{self.wx_access_token}&type=#{options[:type]}"
    params = {:media => File.new("#{options[:path]}")}

    post_request(url,params)

  end


  def message_mass_send_all ( options = {} )
    # options = {:media_type=>"mpnews",:is_to_all=>true ,:media_id=>"wun3zeg4dfHuVoMr2Emqzp-KtSX9lbyGMzFvzhbCY07qAaJaQ5W5XZrgK8p5E2ah"}
    url = "https://api.weixin.qq.com/cgi-bin/message/mass/sendall?access_token=#{self.wx_access_token}"
    if options[:media_type]!="text"
      params = {
        filter:{
          is_to_all: options[:is_to_all],
          group_id: options[:group_id]
        },
        options[:media_type] => {
          :media_id => "#{options[:media_id]}"
        },
        msgtype:"#{options[:media_type]}"
      }.to_json
    else
      params = {
        filter:{
          is_to_all: options[:is_to_all],
          group_id: options[:group_id]
        },
        text: {
          content: "#{options[:content]}"
        },
        msgtype: "text"
      }.to_json

    end
    post_request(url,params)
  end

  def get_request(url)
    JSON.parse(RestClient.get(url))
  end

  def post_request(url,parameters)
    JSON.parse(RestClient.post(url,parameters))
  end
end
