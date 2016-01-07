class HelpMenu < ActiveRecord::Base
  has_many :help_posts, order: 'sort ASC'

  enum_attr :product_line_type, :in => [
    ['winwemedia', 1, '微枚迪'],
    ['youzhe', 2, '优者工作圈'],
  ]

end