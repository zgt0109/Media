class Like < ActiveRecord::Base
  belongs_to :site
  belongs_to :user
  belongs_to :likeable, polymorphic: true

end
