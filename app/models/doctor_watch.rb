# -*- coding: utf-8 -*-
class DoctorWatch < ActiveRecord::Base
  #attr_accessible :doctor_arrange, :end_time, :start_time, :status
  belongs_to :doctor_arrange
  belongs_to :shop_branch
  belongs_to :hospital_doctor
  has_many :doctor_arrange_items

  validates :start_time, presence: true
  validates :end_time,   presence: true

  before_save :order_time

  # scope :available, lambda{ |name| where(name: name) unless name.nil? }

  enum_attr :status, :in => [
    ['start', 1, '出诊'],
    ['stop', -1, '停诊'],
  ]

  enum_attr :is_success, :in => [
    ['deleted', -1, '删除'],
    ['staging', 0, '暂存'],
    ['saved', 2, '保存']
  ]

  def is_multi
    ret = false
    same_doctor_watches = DoctorWatch.where(hospital_doctor_id: self.hospital_doctor_id).where(:is_success => 2)
    same_doctor_watches.each do |watch|
      if watch.doctor_arrange.is_success == 2 # already persistence
        puts "compare #{self.start_time} <= #{watch.end_time} && #{self.end_time} >= #{watch.start_time}"
        if self.start_time <= watch.end_time && self.end_time >= watch.start_time
          ret = true
        end
      end
    end
    return ret
  end

  def arrange_time
    "#{start_time} - #{end_time}"
  end

  def select_time
    "#{start_time.strftime("%H:%M")} - #{end_time.strftime("%H:%M")}"
  end

  def stop!
    update_column("status", -1)
  end

  def start!
    update_column("status", 1)
  end

  def is_full
    return false if self.limit < 0
    current_count = self.doctor_arrange_items.count
    if current_count >= self.limit
      return true
    end
    return false
  end

  def order_time
    if self.start_time > self.end_time
      self.end_time, self.start_time = self.start_time, self.end_time
    end
  end
end
