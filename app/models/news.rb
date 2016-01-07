# == Schema Information
#
# Table name: news
#
#  id            :integer          not null, primary key
#  title         :string(255)      not null
#  content       :text             default(""), not null
#  content_type  :integer          default(1), not null
#  admin_user_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# 如果想使用内容简介，请使用 short_content 字段
class News < ActiveRecord::Base
  #validates :code, presence: true#, uniqueness: { case_sensitive: false }

  belongs_to :admin_user_id

  enum_attr :content_type, :in=>[
    ['company', 2, '公司动态'],
    ['broadcast', 6, '微哥播报'],
    ['industry_news', 7, '行业资讯'],
    ['info', 1, '微营销资讯'],
    ['qa', 3, '微信常见问题'],
    ['clazz', 4, '微信公开课'],
    ['comment', 5, '微商评论'],
  ]
  
  def title
    super.presence || '公告标题'
  end

  def pic_url
    qiniu_image_url(pic) || ''
  end
  # scope :top, -> { where('top_line = true'), order("updated_at asc") }

  def self.top_one
    self.where(top_line: true).order('updated_at desc').first;
  end

  def self.report_json(news)
    news.collect{|n| {img: n.pic_url, title: n.title, desp: n.short_content, link: "/news/#{n.id}"} }
  end

end
