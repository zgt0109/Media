class Kf::Staff < ActiveRecord::Base
  self.table_name = 'kf_staffs'
  establish_connection "kefu_app_#{Rails.env}"

  has_secure_password

  belongs_to :supplier
  belongs_to :wx_mp_user
  belongs_to :account, class_name: 'Kf::Account'

  validates :staff_no, :account_id, presence: true
  validate :check_only_one_admin
  validate :check_unique_staff_no

  before_save :postfix_staff_no

  # attr_accessible :nickname, :password_digest, :public_no, :role, :staff_no, :password, :password_confirmation, :avatar, :wx_mp_user_id, :supplier_id

  def role_name
    self.role == 'admin' ? "管理员权限" : "普通权限"
  end

  def is_staff_no_valid?
    return (Kf::Staff.where(staff_no: postfix_staff_no).count == 0) if self.new_record?
    Kf::Staff.where(staff_no: postfix_staff_no).where("id != ?", self.id).count == 0
  end

  def is_role_valid?
    admin_scope = self.supplier.staffs.where(role: 'admin')
    return true if self.role != 'admin'
    return true if (self.new_record? && admin_scope.count == 0) || (!self.new_record? && admin_scope.where("id not in (?)", self.id).count == 0)
    return false
  end

  private

    def postfix_staff_no
      postfix = "@#{self.supplier.id}"
      postfix_regex = /#{postfix}$/
      unless self.staff_no =~ postfix_regex
        self.staff_no = "#{self.staff_no}#{postfix}"
      end
      self.staff_no
    end

    def check_only_one_admin
      if !is_role_valid?
        self.errors.add(:role, "只能有一个管理员客服")
      end
    end

    def check_unique_staff_no
      if !is_staff_no_valid?
        self.errors.add(:staff_no, "工号已经被人使用")
      end
    end

end