# -*- coding: utf-8 -*-
class HospitalOrder < ActiveRecord::Base
  belongs_to :site
  belongs_to :wx_mp_user
  belongs_to :wx_user
  belongs_to :hospital
  belongs_to :hospital_department
  belongs_to :hospital_doctor
  #attr_accessible :booking_at, :canceled_at, :description, :expired_at, :order_no, :status, :tel, :total_amount, :username
  enum_attr :status, :in => [
                             ['appointment', 1, '已预约'],
                             ['completed', 2, '已就诊'],
                             ['canceled', 3, '已取消'],
                             ['expired', 4, '已过期'],
                            ]

  scope :need_expires, -> { where("booking_at < ? AND status = ?", Time.now, APPOINTMENT) }

  before_create :add_default_properties!, :generate_order_no

  def add_default_properties!
    self.supplier_id = self.hospital_doctor.supplier_id
    self.wx_mp_user_id = self.hospital_doctor.wx_mp_user_id
  end

  def complete!
    update_attributes(status: COMPLETED, completed_at: Time.now)
  end

  def cancele!
    update_attributes(status: CANCELED, canceled_at: Time.now)
  end

  #def complete_cupon
    #if (booking_at + 8.hour) < Time.now and appointment?
      #update_attributes(status: EXPIRED)
      #end
  #end

  def generate_order_no
    now = Time.now
    self.order_no = [now.to_s(:number), now.usec.to_s.ljust(6, '0')].join
  end

end
