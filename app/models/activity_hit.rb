class ActivityHit < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :ahable, polymorphic: true

end
