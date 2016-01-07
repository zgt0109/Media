class WebsiteTag < ActiveRecord::Base
  # attr_accessible :name, :sort
  validates :name, presence: true

  has_many :website_templates
end
