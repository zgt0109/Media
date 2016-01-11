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
    ['upgrade_log', 1, '系统产品升级公告'],
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
