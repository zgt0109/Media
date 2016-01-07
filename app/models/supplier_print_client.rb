# -*- coding: utf-8 -*-
class SupplierPrintClient < ActiveRecord::Base
  # attr_accessible :bottom_img, :client_id, :daymaxnum, :is_banner, :net_name, :public_user_id, :security_code
  validates :client_id, :daymaxnum, :net_name, :mac, presence: true
  validates :bottom_img, presence: true, on: :create
  has_one :supplier_print_picture
  belongs_to :supplier_print
  has_many :supplier_print_pictures
  # mount_uploader :bottom_img, SupplierPrintUploader

  after_save :connect_edit_webservice

  enum_attr :status, :in => [
    ['normal', 1, '启用'],
    ['offline', -1, '禁用'],
  ]

  #temp_id 4格是1 巨屏是2

  # 打印模式 普通照片卡(支持文字)  广告卡  二维码卡(支持文字)  logo卡(支持文字)
  enum_attr :print_mode, :in => [
    ['normal_print', 1, '普通照片卡(支持文字)'],
    ['ad',     2, '广告卡'],
    ['qrcode', 3, '二维码卡(支持文字)'],
    ['logo',   4, 'logo卡(支持文字)']
  ]

  def main_pics_url
    ret = ''
    s = self.main_pic_ids
    if s.blank?

    else
      pics = s.split(";")
      pics.each do |p|
        ret += "#{qiniu_image_url(p)}-sida.jpg;"
      end
    end
    ret
  end

  def main_pic_ids_url
    ret = ''
    s = self.main_pic_ids
    if s.blank?

    else
      pics = s.split(",")
      pics.each do |p|
        ret += "#{qiniu_image_url(p)},"
      end
    end
    ret
  end


  def logo_url_url
    logo_url.present? ? qiniu_image_url(logo_url) : "http://www.winwemedia.com/assets/bg_fm.jpg"
  end

  def left_url_url
    left_url.present? ? qiniu_image_url(left_url) : "http://www.winwemedia.com/assets/bg_fm.jpg"
  end

  def right_url_url
    right_url.present? ? qiniu_image_url(right_url) : "http://www.winwemedia.com/assets/bg_fm.jpg"
  end

  def center_url_url
    center_url.present? ? qiniu_image_url(center_url) : "http://www.winwemedia.com/assets/bg_fm.jpg"
  end

  def bottom_img_url
    bottom_img.present? ? qiniu_image_url(bottom_img) : "http://www.winwemedia.com/assets/bg_fm.jpg"
  end

  #编辑设备基本信息
  def connect_edit_webservice #可以编辑设备
    begin
      url = "http://admin.weixinprint.com/inleader/services/mobileClient?wsdl"
      client = Savon.client do
        wsdl url
        namespace "http://admin.weixinprint.com/"
        endpoint "http://admin.weixinprint.com/inleader/services/mobileClient?wsdl"
      end
      response = client.call(:edit_client_info_byclient_info_id, message:{
        clientId: self.client_id,
        netName: self.net_name,
        daymaxnum: self.daymaxnum,
        bottomImg: "#{self.bottom_img_url}-button.jpg",
      isBanner: self.is_banner ? "0" : "1",   #isBanner是否广告设备：0（是）1（否）只有这两种类型
      publicId: self.supplier_print.public_user_id
      })
      puts response
    rescue
      logger.info "---------------- connect_edit_webservice error -----------------------------"
    end
  end

  # 设备⼴广告图⽚片修改:
  def connect_edit_ad
    url = "http://admin.weixinprint.com/inleader/services/mobileClient?wsdl"
    client = Savon.client do
      wsdl url
      namespace "http://admin.weixinprint.com/"
      endpoint "http://admin.weixinprint.com/inleader/services/mobileClient?wsdl"
    end
    if self.logo_url.present?
      logo_ws = "#{self.logo_url_url}-.jpg"
    else
      logo_ws = "http://www.winwemedia.com/assets/bg_fm.jpg"
    end
    response = client.call(:edit_client_temp_baaner, message:{
      clientId: self.client_id,
      tempId:  self.temp_id, #模版ID,四格版模版 (tempId为1,巨屏版(tempId为2(不允许为空)
      bannerTitle: self.banner_title, #界⾯面标题,
      logoUrl: "#{logo_ws}",
      mainPicIds: "#{self.main_pics_url}",
      leftUrl: "#{self.left_url_url}-sixiao.jpg",
      centerUrl: "#{self.center_url_url}-sixiao.jpg",
      rightUrl: "#{self.right_url_url}-sixiao.jpg",
      newplayUrl: "",
      defaultEwm: self.default_ewm,
      stepWord1: self.step_word1,
      stepWord2: self.step_word2,
      stepWord3: self.step_word3,
      stepWord4: self.step_word4
    })
    # puts response.body
    # response
  end

  def get_client_temp_info
    url = "http://admin.weixinprint.com/inleader/services/mobileClient?wsdl"
    client = Savon.client do
      wsdl url
      namespace "http://admin.weixinprint.com/"
      endpoint "http://admin.weixinprint.com/inleader/services/mobileClient?wsdl"
    end

    response = client.call(:get_client_temp_banner, message:{
      clientId: self.client_id,
      tempId:   self.temp_id
    })
  end

  #获取⼴广告模版信息
  def ad_temp_info
    url = "http://admin.weixinprint.com/inleader/services/mobileClient?wsdl"
    client = Savon.client do
      wsdl url
      namespace "http://admin.weixinprint.com/"
      endpoint "http://admin.weixinprint.com/inleader/services/mobileClient?wsdl"
    end
    #editClientTempBaaner
    response = client.call(:add_weixin_by_org_id, message:{
      clientId: self.client_id,
      tempId:   self.temp_id
    })
#       参数1 clientId(此参数为设备id 即设备列表中的clientId)
# 参数2 tempId模版ID
# Json:
# [{"bannerTitle":"四格版接⼜⼝口测试", "centerUrl":http://img.weixinprint.com/banner/20131231/1388461205445.jpg, "clientId":0,"expand":http://img.weixinprint.com/banner/20131231/1388461205680.jpg,
# 返回值 "id":24,"leftUrl":http://img.weixinprint.com/banner/20131231/1388461205266.jpg, (json) "logoUrl":http://img.weixinprint.com/banner/20131231/1388460940742.jpg,
# "mainpicIds":"http://img.weixinprint.com/banner/20131231/1388460940963.jpg;
# http://img.weixinprint.com/banner/20131231/1388460941313.jpg;", "newplayUrl":"","rightUrl":"http://img.weixinprint.com/banner/20131231/1388461205569.jpg", "status":1,"stepWord1":"关注hrt","stepWord2":"发照⽚片546","stepWord3":"输⼊入sdfa", "stepWord4":"⻢马上制作afgf","tempId":0}]
  end

end
