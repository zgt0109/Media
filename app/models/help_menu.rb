class HelpMenu < ActiveRecord::Base
  has_many :help_posts, order: 'sort ASC'

end