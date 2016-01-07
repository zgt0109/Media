class HospitalDoctorDepartment < ActiveRecord::Base
  belongs_to :hospital_doctor
  belongs_to :hospital_department
  # attr_accessible :title, :body
end
