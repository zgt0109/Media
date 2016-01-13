# -*- coding: utf-8 -*-
class Print < ActiveRecord::Base
  validates :account_id, :token, :url, presence: true
  validates :token, uniqueness: { case_sensitive: false }

  belongs_to :account
  has_many :activities, as: :activityable
  accepts_nested_attributes_for :activities

  def printers
    activities.select { |a| [46,47].include? a.activity_type_id }
  end

  enum_attr :status, :in=>[
    ['normal', 1, '启用'],
    ['offline', -1, '禁用'],
  ]

  def pic_url
    pic.present? ? qiniu_image_url(pic) : '/assets/bg_fm.jpg'
  end

  def self.print_url(account_id)
    Hash[pluck(:account_id, :url)][account_id]
  end

  def self.postcard?(wx_user)
    wx_user.postcard? && print_url(wx_user.supplier_id)
  end

  def self.respond_postcard_img(wx_user, wx_mp_user, raw_post)
    url = print_url(wx_mp_user.supplier_id)
    result = RestClient.post(url, raw_post, content_type: :xml, accept: :xml)
    Print.normalize_wx_text_response(wx_user, wx_mp_user, result)
  end

  def self.respond_text(wx_user, wx_mp_user, word, raw_post)
    if word == '微打印'
      wx_user.postcard!
      Weixin.respond_text(wx_user.openid, wx_mp_user.openid, '您已经进入打印模式，请发送图片给我。退出打印模式请回复：退出')
    elsif wx_user.enter_postcard?
      if word == '退出'
        wx_user.normal!
        Weixin.respond_text(wx_user.openid, wx_mp_user.openid, '您已经退出打印模式')
      else
        print_url = print_url(wx_user.supplier_id)
        return unless print_url
        wx_user.touch :match_at
        result = RestClient.post(print_url, raw_post, content_type: :xml, accept: :xml)
        Print.normalize_wx_text_response(wx_user, wx_mp_user, result)
      end
    end
  end

  private
    def self.normalize_wx_text_response(wx_user, wx_mp_user, result)
      if result.start_with?('<xml>')
        result
      else
        WinwemediaLog::Base.logger('wxapi', "image_request response: #{result}")
        Weixin.respond_text(wx_user.openid, wx_mp_user.openid, '打印失败，请重新上传图片')
      end
    end
end
