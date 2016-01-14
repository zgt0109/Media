class CollegeEnroll < ActiveRecord::Base
  # attr_accessible :title, :body

  validates :user_id, presence: true

  belongs_to :college
  belongs_to :college_major

  before_create :given_default_attrs

  private

  def given_default_attrs
    return unless self.college
    self.site_id = self.college.site_id
  end

end
