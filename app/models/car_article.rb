# == Schema Information
#
# Table name: car_articles
#
#  id           :integer          not null, primary key
#  car_shop_id  :integer          not null
#  title        :string(255)      not null
#  content      :text             default(""), not null
#  status       :integer          default(1), not null
#  article_type :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class CarArticle < ActiveRecord::Base
	validates :title, :content, :article_type, presence: true

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除']
  ]

  enum_attr :article_type, :in => [
    ['default', -1, ''],
    ['latest', 0, '最新'],
    ['commendatory', 1, '推荐']
  ]

	def delete!
		update_attributes(status: DELETED) if normal?
	end
end

