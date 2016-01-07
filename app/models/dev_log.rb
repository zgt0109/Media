# == Schema Information
#
# Table name: dev_logs
#
#  id            :integer          not null, primary key
#  content_type  :integer          default(1), not null
#  admin_user_id :integer
#  title         :string(255)
#  content       :text             default(""), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class DevLog < ActiveRecord::Base
  # attr_accessible :content, :operator, :title
  validates :title, :content, :content_type, presence: true

  belongs_to :admin_user

  enum_attr :content_type, :in=>[
    ['new_function', 1, '新增功能'],
    ['optimize_content', 2, '优化内容'],
    ['repair_bug', 3, '修复BUG'],
  ]

  enum_attr :product_line_type, :in => [
    ['vcl', 1, '微枚迪'],
    ['oa', 2, '优者工作圈'],
    ['fxt', 3, '优折赚钱宝'],
  ] 

  def content_text
    doc = Nokogiri::HTML(content)
    doc.content
  end

end
