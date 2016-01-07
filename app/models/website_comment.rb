# == Schema Information
#
# Table name: website_comments
#
#  id                 :integer          not null, primary key
#  website_article_id :integer          not null
#  name               :string(255)
#  content            :text
#  status             :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class WebsiteComment < ActiveRecord::Base
  belongs_to :website_article
  attr_accessible :content, :name, :status
end
