class SnCodeScanLog < ActiveRecord::Base
  # attr_accessible :title, :body
  scope :today, -> { where("date(created_at) = ?", Date.today) }
end
