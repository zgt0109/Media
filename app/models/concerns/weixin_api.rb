module Concerns::WeixinApi

# 获取用户列表
  def wx_user_list
    url = "https://api.weixin.qq.com/cgi-bin/user/get?access_token=#{self.wx_access_token}&next_openid="
    get_request(url)["data"]["openid"]
  end

# 获取用户基本信息
  def wx_user_info
    wx_user_list.each do |l|
      @wxuser=WxUser.new(wx_mp_user_id: self.id)
      url = "https://api.weixin.qq.com/cgi-bin/user/info?access_token=#{self.wx_access_token}&openid=#{l}&lang=zh_CN"
      parameters = JSON.parse(get_request(url))
      @wxuser.update_attributes(parameters)
      @wxuser.save
    end
  end
# 查询所有分组
  def wx_user_group_list
    #code
    url = "https://api.weixin.qq.com/cgi-bin/groups/get?access_token=#{self.wx_access_token}"
    groups = get_request(url)["groups"]
    # groups.each do |g|
    #   group = WxUserGroup.where(groupid:g["id"]).first_or_create
    #   group.update_attributes(name: g["name"],count:g["count"],wx_mp_user_id:self.id,groupid:g["id"])
    # end
  end
# 创建分组
  def create_user_group name
    url = "https://api.weixin.qq.com/cgi-bin/groups/create?access_token=#{self.wx_access_token}"
    parameters = {:group => {:name => name}}.to_json
    post_request(url,parameters)
  end
  # 修改分组名
  def change_group_name options={}

    parameters = {:group =>{:id =>options[:id],:name =>options[:name]}}.to_json
    url = "https://api.weixin.qq.com/cgi-bin/groups/update?access_token=#{self.wx_access_token}"
    post_request(url,parameters)

  end
  # 删除分组
  def delete_wx_group id
    url="https://api.weixin.qq.com/cgi-bin/groups/delete?access_token=#{self.wx_access_token}"
    parameters = {:group=>{:id=>id}}.to_json
    post_request(url,parameters)
  end
# 批量移动用户分组
  def move_wx_user_list options={}
    # options = {:openid_list => ["oMtqxt1LlPdU-zdC3n4DhL6mEEDU"],:to_groupid =>101}
    url = "https://api.weixin.qq.com/cgi-bin/groups/members/batchupdate?access_token=#{self.wx_access_token}"
    parameters = {:openid_list => options[:openid_list],:to_groupid => options[:to_groupid]}.to_json
    post_request(url,parameters)
  end
# 移动用户分组
  def move_wx_user options={}
    # options = {:openid => "oMtqxt1LlPdU-zdC3n4DhL6mEEDU",:to_groupid =>100}
    url = "https://api.weixin.qq.com/cgi-bin/groups/members/update?access_token=#{self.wx_access_token}"
    parameters = {:openid =>options[:openid],:to_groupid => options[:to_groupid]}.to_json
    post_request(url,parameters)
  end

  # 查询用户所在分组
  def get_wx_user_id openid
    #code
    url = "https://api.weixin.qq.com/cgi-bin/groups/getid?access_token=#{self.wx_access_token}"
    parameters = {:openid=> openid}.to_json
    post_request(url,parameters)["groupid"].to_i
  end

  # 设置备注名
  def set_remark options={}
    options = {:openid => "oMtqxt1LlPdU-zdC3n4DhL6mEEDU" ,:remark => "pangzi"}
    url = "https://api.weixin.qq.com/cgi-bin/user/info/updateremark?access_token=#{self.wx_access_token}"
    parameters = {:openid =>options[:openid] ,:remark =>options[:remark]}.to_json
    post_request(url,parameters)
    WxUser.find_by_openid(options[:openid]).update_attributes(remark:options[:remark])
  end

  def get_request(url)
    JSON.parse(RestClient.get(url))
  end

  def post_request(url,parameters)
    JSON.parse(RestClient.post(url,parameters))
  end
end
