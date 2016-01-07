class BookRule < ActiveRecord::Base
  belongs_to :shop_branch
  has_many :book_time_ranges
  attr_accessible :is_limit_money, :type, :rule_type, :shop_branch_id, :book_phone, :booked_minute, :cancel_rule, :created_minute, :description, 
  :is_in_branch, :is_in_normal, :is_in_queue, :is_pay_cash, :is_pay_online, :is_send_captcha, :min_money, :preview_day, :book_time_ranges_attributes, 
  :is_limit_day, :is_limit_time, :is_open_hall, :is_open_loge, :hall_limit_money, :loge_limit_money, :is_pay_balance

  validates :shop_branch_id, presence: true

  accepts_nested_attributes_for :book_time_ranges, :allow_destroy => true, reject_if: proc { |attributes| attributes['start_time'].blank? || attributes['end_time'].blank? }

  after_save :cleanup

  enum_attr :rule_type, :in => [
    ['book_dinner',1, '订餐规则'],
    ['book_table', 2, '订座规则'],
    ['take_out',   3, '外卖规则'],
  ]

  enum_attr :cancel_rule, :in => [
    ['no_limit',         -1, '不限'],
    ['can_not_cancel',   -2, '不可取消'],
    ['by_created_at',    -3, '订单生成'],
    ['by_booked_at',     -4, '订餐时间'] 
  ]


  def copy_settings_to_branches shop_branches
    shop_branches.each do |branch|
      branch.book_dinner_rule.destroy if self.book_dinner?
      branch.book_table_rule.destroy if self.book_table?
      branch.take_out_rule.destroy if self.take_out?

      copy_rule = self.dup
      copy_rule.shop_branch_id = branch.id
      copy_rule.book_phone = branch.tel
      copy_rule.save!

      self.book_time_ranges.each do |range|
        new_range = range.dup
        new_range.book_rule_id = copy_rule.id
        new_range.save!
      end
    end
  end

  def generate_date_range
    ret = ""
    sd = Time.now.to_date

    if self.preview_day.blank? || self.preview_day < 0
      ed = sd + 60
    else
      ed = sd + self.preview_day
    end

    sd.upto(ed) { |date|
      ret += "<option value='#{date}'>#{date}</option>";
    }

    ret
  end

  def include_time_now
    if self.is_limit_time
      self.book_time_ranges.each do |range|
        return true if range.include_time_now
      end
    else
      return true
    end
    return false
  end

  def generate_time_range is_full
    ret = Array.new

    # invoke book time range
    if self.is_limit_time
      self.book_time_ranges.each do |range|
        ret += range.generate_order_time is_full
      end
    else
      # no limit generate all
      ret += BookTimeRange.new.generate_order_time(is_full)
    end

    ret.uniq.sort_by{|e| e.split(":").join.to_i }

    if ret.count > 0 && (ret[0].split(":")[0].to_i == Time.now.hour)
      ret.delete_at(0) if (ret[0].split(":")[1].to_i - Time.now.to_i) < 15
    end

    ret
  end

  def cleanup
    if self.is_limit_time && self.book_time_ranges.count == 0
      self.update_column("is_limit_time", false)
    end

    if self.is_limit_day && (self.preview_day.blank? || self.preview_day < 0)
      self.update_column("is_limit_day", false)
    end

    unless self.book_table?
      if self.is_limit_money && (self.min_money.blank? || self.min_money <= 0)
        self.update_column("is_limit_money", false)
      end
    end

    if self.cancel_rule == -3 && (self.created_minute.blank? || self.created_minute <= 0)
      self.update_column("cancel_rule", -1)
    end

    if self.cancel_rule == -4 && (self.booked_minute.blank? || self.booked_minute <= 0)
      self.update_column("cancel_rule", -1)
    end

    if self.book_table?
      if (self.hall_limit_money.blank? || self.hall_limit_money <= 0) && (self.loge_limit_money.blank? || self.loge_limit_money <= 0)
        self.update_column("is_limit_money", false)
      else
        self.update_column("hall_limit_money", 0) if self.hall_limit_money.blank? 
        self.update_column("loge_limit_money", 0) if self.loge_limit_money.blank?
      end
    end
  end

end
