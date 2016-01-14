class CollegeBranch < ActiveRecord::Base
  belongs_to :college
  belongs_to :site
  belongs_to :province
  belongs_to :city
  belongs_to :district

  validates :name, :tel, :address, presence: true
end
