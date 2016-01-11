# -*- coding: utf-8 -*-
class HospitalDoctor < ActiveRecord::Base
  validates :name, :description, presence: true
  validates :limit_register_count, numericality: { greater_than_or_equal_to: -1 }
  validates_presence_of :hospital_departments, message: '科室不能为空'
  validates_presence_of :hospital_job_titles, message: '职称不能为空'

  belongs_to :site
  belongs_to :wx_mp_user
  belongs_to :hospital
  has_many :hospital_orders
  has_many :hospital_comments
  has_many :hospital_doctor_departments
  has_many :hospital_departments, through: :hospital_doctor_departments
  has_many :hospital_doctor_job_titles
  has_many :hospital_job_titles, through: :hospital_doctor_job_titles
  has_many :doctor_arranges
  has_many :doctor_watches, through: :doctor_arranges
  has_many :doctor_arrange_items, through: :doctor_watches
  # has_many :hospital_job_titles

  enum_attr :gender, :in => [
    ['man', 1, '男'],
    ['woman', 2, '女'],
  ]

  enum_attr :status, :in => [
    ["normal", 1, "正常"],
    ["deleted", 2, "已删除"],
  ]

  scope :online, -> { where("is_online = ?", 1) }

  default_scope where(["hospital_doctors.status = ? ", 1 ])

  before_create :add_default_properties!

  def avatar_url(type = :large)
    qiniu_image_url(avatar_key) || (avatar? ? avatar.try(type) : nil)
  end

  def delete!
    update_attributes(status: DELETED)
  end

  def toggle_is_online
    self.is_online = !self.is_online
    self.save
  end

  def is_full
    self.doctor_watches.find_each do |watch|
      if watch.is_full

      else
        return false
      end
    end
    return true
  end

  def has_future_arrange
    self.doctor_watches.where("doctor_watches.start_time > ?", Time.now).where(status: 1).count > 0
  end

  private

  def add_default_properties!
    return unless self.hospital

    self.supplier_id = self.hospital.supplier_id
    self.wx_mp_user_id = self.hospital.wx_mp_user_id
  end

end
