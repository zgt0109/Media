# -*- coding: utf-8 -*-
class DoctorArrange < ActiveRecord::Base
  belongs_to :shop_branch
  belongs_to :hospital_department
  belongs_to :hospital_doctor
  belongs_to :hospital
  belongs_to :supplier
  has_many :doctor_watches, :dependent => :destroy
  #after_create :create_doctor_watches
  #attr_accessible :arrange_limit, :end_time, :start_time, :time_limit, :week
  validates :end_time, presence: true
  validates :start_time, presence: true
  validates :hospital_doctor_id, presence: true
  validates :shop_branch_id, presence: true
  validates :hospital_department_id, presence: true
  validates :arrange_limit, numericality: { only_integer: true }
  validates :time_limit,    numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 7 }

  before_save :order_time

  enum_attr :status, :in => [
    ['start', 1, '出诊'],
    ['stop', -1, '停诊'],
  ]

  enum_attr :week, :in => [
  	['mon',  1, '周一'],
  	['tues', 2, '周二'],
  	['wed',  3, '周三'],
  	['thur', 4, '周四'],
  	['fri',  5, '周五'],
  	['sat',  6, '周六'],
  	['sun',  0, '周日']
  ]

  def has_multi
    ret = false
    self.doctor_watches.each do |w|
      if w.is_multi
        ret = true
        self.is_success = 0 #should be delete
      end
    end
    return ret
  end

  def time_range
    "#{start_time}  #{end_time}"
  end

  def arrange_time
    "#{week_name} #{start_time} #{end_time}"
  end

  def is_duplicate
    ret = false
    DoctorArrange.where(:hospital_doctor_id => self.hospital_doctor_id).where(:week => self.week).where(is_success: 2).each do |da|
      if (should_switch_time_string(da.end_time, self.start_time) && should_switch_time_string(self.end_time, da.start_time) )
        ret = true
      end
    end
    return ret
  end

  def update_self
    # will update all the doctor watches from now
    # update shop_branch start_time and end time

    # check self multi?

    #1. set relative watches status as deleted
    #2. create new set of watches (setted staging) and check if multi
    #3. if all the new watches validate pass, delete "deleted" watches and set new watches save
    #4. if new watches not validated, then delete them, and set deleted saved with message

    puts ".................... into update_self method ......................."

    ret = true
    update_range = self.doctor_watches.where("end_time > ?", Time.now)
    puts "------------------- show update range -----------------------------"
    success_watches = Array.new
    update_range.each do |w|
      w.update_column("is_success", -1)
    end
    # 1. finish

    create_doctor_watches 0

    self.doctor_watches.where(is_success: 0).each do |w|
      if w.is_multi
        ret = false
      end
    end

    # final
    if ret
      self.doctor_watches.where(is_success: -1).each do |w|
        w.destroy
      end
      self.doctor_watches.where(is_success: 0).each do |w|
        w.update_column("is_success", 2)
      end
    else
      self.doctor_watches.where(is_success: -1).each do |w|
        w.update_column("is_success", 2)
      end
      self.doctor_watches.where(is_success: 0).each do |w|
        w.destroy
      end
    end

  end

  def create_doctor_watches s_status
    puts "according doctor arrange to crate doctor watches --------------------------"
    sd = Time.now.to_date
    ed = sd + self.time_limit
    puts "===============create range is #{sd} => #{ed}========================"
    sd.upto(ed) { |date|
      if date.wday == self.week
        w = self.doctor_watches.new
        w.start_time = DateTime.parse(date.to_s + " #{self.start_time}").change(:offset => "+0800")
        w.end_time   = DateTime.parse(date.to_s + " #{self.end_time}").change(:offset => "+0800")
        w.limit = self.arrange_limit
        w.status = 1
        w.shop_branch_id = self.shop_branch_id
        w.hospital_doctor_id = self.hospital_doctor_id
        if(self.doctor_watches
          .where(:start_time => w.start_time)
          .where(:end_time => w.end_time)
          .where(:is_success => 2)
          .count > 0)
          puts "-------------- created doctor watches is multi -------no needt to create----"
        else
          w.is_success = s_status
          w.save!
          puts "-------------success save one watch =======#{w.inspect}================="
        end
      end
    }
  end

  def order_time
    if should_switch_time_string(self.start_time, self.end_time)
      self.end_time, self.start_time = self.start_time, self.end_time
    end
  end

  private

  def should_switch_time_string(s_time, e_time)
    ret = false
    s = s_time.split(":")
    d = e_time.split(":")
    if s[0].to_i > d[0].to_i
      ret = true
    elsif (s[0].to_i == d[0].to_i && s[1].to_i >= d[1].to_i)
      ret = true
    end
    return ret
  end

end
