class WebsiteTag < ActiveRecord::Base
  has_many :website_templates
end
