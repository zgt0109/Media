module WxCardApi
  
  def card_base_info_attrs
    {
      # logo_url:         qiniu_image_url("Fs31wr469Kg5KcnzZx7qodXwWQOC"),
      # logo_url:         "https://mmbiz.qlogo.cn/mmbiz/Fd1Sbp4NohK8BHoCRRaWMZu2rArbHBe2wcO0uiazhp3f26NRcybNQLKPr6QUiaRtwK3D2v36nyC9tib0CGtfNpsfQ/0",
      logo_url:         qiniu_logo_url,
      brand_name:       brand_name,
      code_type:        code_type,
      title:            title,
      sub_title:        sub_title,
      color:            color,
      notice:           notice,
      service_phone:    service_phone,
      description:      description,
      date_info:        date_info,
      sku:              sku,
      use_limit:        use_limit,
      get_limit:        get_limit,
      use_custom_code:  use_custom_code,
      bind_openid:      bind_openid,
      can_share:        can_share,
      can_give_friend:  can_give_friend,
      location_id_list: location_id_list,
      url_name_type:    url_name_type,
      custom_url:       custom_url,
      source:           source
    }
  end

  def data_json
    data_json = {card: {card_type: card_type}}
    data_json[:card][card_type.downcase] = card_type_specific_info.merge!(base_info: card_base_info_attrs)
    data_json
  end

  %w(general_coupon groupon gift cash discount).each do |name|
    define_method "card_#{name}_attrs" do
      card_base_info_attrs.merge(card_type_specific_info)
    end 
  end
  
  def card_attrs
    {card: {card_type: card_type}}.merge({card_type.downcase => send("card_#{card_type.downcase}_attrs")})
  end

  def test_wx_user_attrs
    {
      openid: [
        "oblD8jot26QcHZwGc69RWW855Ppg",
        "oblD8jt3cZK877rLCFB4DDucGjyo",
        "oblD8juTQgUg3PFFOn11oXfACcYM",
        "oblD8jviiH94I4oTaQ_SBdVGKAAw"
        ], 
      username: [
        "zk313822030",
        "zhilin1818",
        "lifuzho",
        "manmannet"
        ]
    }.to_json
  end
 
  #创建微信卡券
  def card_create
    # url = "https://api.weixin.qq.com/card/create?access_token=TTXU96hw2OspBEyErpN5srtvcdcS8xlfMMpO-On9qUMzp5HWxMDnBPwIgdQQkDBmwXW5B8hPM2VN2bj1XGmzCuRRQ00JW5NTMphOU7iCtJo"
    url = "https://api.weixin.qq.com/card/create?access_token=#{wx_mp_user.wx_access_token}"
    Rails.logger.info "========#{data_json.to_json}========="
    result = JSON.parse(RestClient.post(url, JSON.generate(data_json)))
    Rails.logger.info "========#{result}========="
    if result['errcode'].to_i == 0 && result['errmsg'].eql?('ok')
      # update_attributes!(card_id: result['card_id'])
      self.card_id = result['card_id']
    elsif result['errcode'].to_i == 40079
      errors.add(:base, "固定时间不正确")
    else
      errors.add(:base, "创建微信卡券失败")
    end
  rescue => e
    errors.add(:base, "调用微信创建卡券API失败")
  ensure
    return errors.blank?
  end
  
  #删除微信卡券
  def card_delete
    url = "https://api.weixin.qq.com/card/delete?access_token=#{wx_mp_user.wx_access_token}"
    result = JSON.parse(RestClient.post(url, {card_id: card_id}.to_json))
    Rails.logger.info "========#{result}========="
    if result['errcode'].to_i == 0 && result['errmsg'].eql?('ok')
      #更新本地卡券的状态
      deleted!
    else
      errors.add(:base, "删除微信卡券失败")
    end
  rescue => e
    errors.add(:base, "调用微信卡券删除API失败")
  ensure
    return errors.blank?
  end
   
  #查询微信卡券详情
  def card_get
    pp card_id
    url = "https://api.weixin.qq.com/card/get?access_token=#{wx_mp_user.wx_access_token}"
    result = JSON.parse(RestClient.post(url, {card_id: card_id}.to_json))
    if result['errcode'].to_i == 0 && result['errmsg'].eql?('ok')
      # TODO 更新本地卡券的属性
    else
      errors.add(:base, "查询微信卡券失败")
    end
  rescue => e
    errors.add(:base, "调用查询微信卡券API失败")
  ensure
    return errors.blank?
  end

  #设置微信卡券失效
  def card_code_unavailable
    url = "https://api.weixin.qq.com/card/code/unavailable?access_token=#{wx_mp_user.wx_access_token}"
    result = JSON.parse(RestClient.post(url, {card_id: card_id, code: code}.to_json))
    if result['errcode'].to_i == 0 && result['errmsg'].eql?('ok')
      # TODO 更新本地卡券的状态
    else
      errors.add(:base, "设置微信卡券失效失败")
    end
  rescue => e
    errors.add(:base, "调用设置微信卡券失效API失败")
  ensure
    return errors.blank?
  end
 
  #卡券核销消耗 code
  def card_code_consume(code)
    url = "https://api.weixin.qq.com/card/code/consume?access_token=#{wx_mp_user.wx_access_token}"
    result = JSON.parse(RestClient.post(url, {card_id: card_id, code: code}.to_json))
    Rails.logger.info "========#{result}========="
    if result['errcode'].to_i == 0 && result['errmsg'].eql?('ok')
      # TODO 更新本地卡券的状态
      result['errcode']
    else
      errors.add(:base, "卡券核销消耗 code失败")
    end
  rescue => e
    errors.add(:base, "调用卡券核销消耗 code API失败")
  ensure
    return errors.blank?
  end

  #设置测试用户白名单
  def test_white_list
    url = "https://api.weixin.qq.com/card/testwhitelist/set?access_token=#{wx_mp_user.wx_access_token}"
    result = JSON.parse(RestClient.post(url, test_wx_user_attrs))
    Rails.logger.info "========#{result}========="
    if result['errcode'].to_i == 0 && result['errmsg'].eql?('ok')
      #申请通过
    else
      errors.add(:base, "申请失败")
    end
  rescue => e
    errors.add(:base, "申请失败，接口异常")
  ensure
    return errors.blank?
  end

end
