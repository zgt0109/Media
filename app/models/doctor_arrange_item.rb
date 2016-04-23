# -*- coding: utf-8 -*-
class DoctorArrangeItem < ActiveRecord::Base
  belongs_to :hospital_doctor
  belongs_to :hospital_department
  belongs_to :doctor_watch
  belongs_to :user
  belongs_to :shop_branch

  before_create :add_default_attrs
  enum_attr :status, :in => [
                             ['appointment', 1, '已预约'],
                             ['completed', 2, '已就诊'],
                             ['canceled', 3, '已取消'],
                             ['expired', 4, '已过期'],
                            ]

  scope :need_expires, -> { where("end_time < ? AND status = ?", Time.now, APPOINTMENT) }

  def complete!
    update_attributes(status: COMPLETED)
  end

  def cancel!
    update_attributes(status: CANCELED)
  end

  private

  def add_default_attrs
    self.order_no = Concerns::OrderNoGenerator.generate
    self.hospital_doctor_id = self.doctor_watch.doctor_arrange.hospital_doctor_id
    self.hospital_department_id = self.doctor_watch.doctor_arrange.hospital_department_id
    self.shop_branch_id = self.doctor_watch.shop_branch_id
    self.start_time = self.doctor_watch.start_time
    self.end_time = self.doctor_watch.end_time
  end

end
