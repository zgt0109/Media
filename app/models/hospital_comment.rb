class HospitalComment < ActiveRecord::Base
  belongs_to :site
  belongs_to :hospital
  belongs_to :hospital_doctor
  belongs_to :user
  #attr_accessible :content
  
  before_create :add_default_properties!
  
  def add_default_properties!
    self.site_id = self.hospital_doctor.site_id
  end
end
