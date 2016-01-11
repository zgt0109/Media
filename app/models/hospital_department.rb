class HospitalDepartment < ActiveRecord::Base
  validates :name, uniqueness: {:scope => [:hospital_id, :status], message: '科室不能重复', case_sensitive: false }, presence: true, :if => :valStatus?
  validates :sort, presence: true
  
  belongs_to :site
  belongs_to :wx_mp_user
  belongs_to :hospital
  
  belongs_to :parent, class_name: 'HospitalDepartment', foreign_key: :parent_id
  has_many :children, class_name: 'HospitalDepartment', foreign_key: :parent_id
  
  has_many :hospital_orders
  has_many :hospital_doctor_departments
  has_many :hospital_doctors, through: :hospital_doctor_departments
  #attr_accessible :description, :name, :sort, :status
  
  default_scope where(["hospital_departments.status = ? ", 1 ])
  
  enum_attr :status, :in => [
    ["normal", 1, "正常"],
    ["deleted", 2, "已删除"],
  ]
  
  scope :root, ->{where(parent_id: 0)}
  
  before_create :add_default_attrs

  def valStatus?
    status != 2
  end

  def has_children?
    children.count > 0
  end
  
  def delete!
    update_attributes(status: DELETED)
  end

  def can_delete?
    self.hospital_doctors.count == 0 && self.children.count == 0
  end
  
  def add_default_attrs
    return unless hospital
    self.supplier_id = hospital.supplier_id
    self.wx_mp_user_id = hospital.wx_mp_user_id
  end
end
