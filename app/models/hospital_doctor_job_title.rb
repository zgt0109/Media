class HospitalDoctorJobTitle < ActiveRecord::Base
  belongs_to :hospital_doctor
  belongs_to :hospital_job_title
  # attr_accessible :title, :body
end
