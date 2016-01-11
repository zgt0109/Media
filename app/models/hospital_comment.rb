class HospitalComment < ActiveRecord::Base
  belongs_to :site
  belongs_to :wx_mp_user
  belongs_to :hospital
  belongs_to :hospital_doctor
  belongs_to :wx_user
  #attr_accessible :content
  
  before_create :add_default_properties!
  
  def add_default_properties!
    self.supplier_id = self.hospital_doctor.supplier_id
    self.wx_mp_user_id = self.hospital_doctor.wx_mp_user_id
  end
end
