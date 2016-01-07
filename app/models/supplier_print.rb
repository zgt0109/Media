# -*- coding: utf-8 -*-
class SupplierPrint < ActiveRecord::Base
  validates :supplier_id, :token, :url, presence: true
  validates :token, uniqueness: { case_sensitive: false, scope: :machine_type }
  validates :pic, presence: true, on: :create, unless: :welomo?
  validates :public_name, presence: true, unless: :welomo?

  belongs_to :supplier
  has_many :supplier_print_clients

  enum_attr :machine_type, :in => [
    ['small_machine', 1, '小打印机'],
    ['big_machine',   2, '大打印机'],
    ['welomo',3, '通用打印机']
  ]
  enum_attr :version_type, :in => [ ['text', 1, '文字卡'], ['ad', 2, '广告卡'] ]
  enum_attr :status, :in=>[
    ['normal', 1, '启用'],
    ['offline', -1, '禁用'],
  ]

  after_create :connect_create_webservice
  after_update :connect_edit_webservice

  scope :small, ->  { where('machine_type = ?', SMALL_MACHINE) }
  scope :big, ->    { where('machine_type = ?', BIG_MACHINE) }
                   
  def pic_url
    pic.present? ? qiniu_image_url(pic) : '/assets/bg_fm.jpg'
  end

  def self.print_url(supplier_id)
    Hash[pluck(:supplier_id, :url)][supplier_id]
  end

  def self.postcard?(wx_user)
    wx_user.postcard? && print_url(wx_user.supplier_id)
  end
  
  def connect_create_webservice
    if self.machine_type == 1
      weixincodeimg = "#{self.pic_url}-.jpg"
      version_type = self.version_type
      public_user_name = self.public_name
      url = 'http://admin.weixinprint.com/inleader/services/mobileVsins?wsdl'
      client = Savon.client do
        wsdl url
        namespace 'http://admin.weixinprint.com/'
        endpoint 'http://admin.weixinprint.com/inleader/services/mobileVsins?wsdl'
      end
      response = client.call(:add_weixin_by_org_id, message:{ orgId: "64", weiXinCodeImg: weixincodeimg, versionType: version_type, publicUserName: public_user_name })
      json = JSON.parse response.to_json
      ret = json['add_weixin_by_org_id_response']['add_weixin_by_org_id_return']
      reload
      self.update_attributes(:public_user_id => ret, :url => "http://inleader.weixinprint.com/weixin?publicUserId=#{ret}")
    end
  rescue
  end

  def connect_edit_webservice
    if self.machine_type == 1
      url = 'http://admin.weixinprint.com/inleader/services/mobileVsins?wsdl'
      client = Savon.client do
        wsdl url
        namespace 'http://admin.weixinprint.com/'
        endpoint 'http://admin.weixinprint.com/inleader/services/mobileVsins?wsdl'
      end
      weixincodeimg = "#{self.pic_url}-.jpg"
      response = client.call(:edit_weixin_bypublic_id, message:{ publicId: self.public_user_id, weiXinCodeImg: weixincodeimg, versionType: self.version_type })
      puts response
    end
  rescue
  end

  def self.respond_small_print_img(wx_user, wx_mp_user, raw_post)
    url = wx_mp_user.supplier.supplier_prints.small.first.url
    result = RestClient.post(url, raw_post, content_type: :xml, accept: :xml)
    SupplierPrint.normalize_wx_text_response(wx_user, wx_mp_user, result)
  end

  def self.respond_postcard_img(wx_user, wx_mp_user, raw_post)
    url = print_url(wx_mp_user.supplier_id)
    result = RestClient.post(url, raw_post, content_type: :xml, accept: :xml)
    SupplierPrint.normalize_wx_text_response(wx_user, wx_mp_user, result)
  end

  def self.respond_text(wx_user, wx_mp_user, word, raw_post)
    if word == '微打印'
      wx_user.postcard!
      Weixin.respond_text(wx_user.uid, wx_mp_user.uid, '您已经进入打印模式，请发送图片给我。退出打印模式请回复：退出')
    elsif wx_user.enter_postcard?
      if word == '退出'
        wx_user.normal!
        Weixin.respond_text(wx_user.uid, wx_mp_user.uid, '您已经退出打印模式')
      else
        print_url = print_url(wx_user.supplier_id)
        return unless print_url
        wx_user.touch :match_at
        result = RestClient.post(print_url, raw_post, content_type: :xml, accept: :xml)
        SupplierPrint.normalize_wx_text_response(wx_user, wx_mp_user, result)
      end
    end
  end

  def self.respond_small_print(wx_user, wx_mp_user, activity)
    return if activity.nil? || !activity.supplier_print?

    if activity.supplier.supplier_prints.small.count > 0
      wx_user.print! # 公众号有打印设备, 那么就进入打印模式
      nil
    else #没有打印设备
      wx_user.normal!
      Weixin.respond_text(wx_user.uid, wx_mp_user.uid, '该公众帐号没有打印设备')
    end
  end

  private
    def self.normalize_wx_text_response(wx_user, wx_mp_user, result)
      if result.start_with?('<xml>')
        result
      else
        WinwemediaLog::Base.logger('wxapi', "image_request response: #{result}")
        Weixin.respond_text(wx_user.uid, wx_mp_user.uid, '打印失败，请重新上传图片')
      end
    end
end
