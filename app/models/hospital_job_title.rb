class HospitalJobTitle < ActiveRecord::Base
  belongs_to :site
  belongs_to :wx_mp_user
  belongs_to :hospital
  
  # has_many :hospital_doctors, through: :hospital_doctor_job_titles
  # has_many :hospital_doctor_job_titles
  has_many :hospital_doctors
  #attr_accessible :description, :name, :sort, :status
  # validates :name, presence: true, uniqueness: { case_sensitive: false } 
  default_scope where(["status = ? ", 1 ])
  
  enum_attr :status, :in => [
    ["normal", 1, "正常"],
    ["deleted", 2, "已删除"],
  ]

  before_create :add_default_properties!
  
  def delete!
    update_attributes(status: DELETED)
  end

  def add_default_properties!
    self.supplier_id = self.hospital.supplier_id
    self.wx_mp_user_id = self.hospital.wx_mp_user_id
  end
end
