# encoding: utf-8

require "wx_reply_message/wshop"
require "wx_reply_message/wmall"
require "wx_reply_message/wlife"
require "wx_reply_message/shequ"

def generate_sn_by_timestamp
  DateTime.now.strftime("%y%m%d%6N") + Random.rand(100...1000).to_s
end

class String
  def split_all(content='')
    content = self if content.empty?
    content.split(/、|，|,|;|；|\ +|\||\r\n/) if content.class.eql? self.class
    #content.split(/[\p{Punctuation}\p{Symbol}]/) if content.class.eql? self.class
  end

  def to_search_string
    self.gsub(/[\p{Punctuation}\p{Symbol}]/, " ")
  end
end
