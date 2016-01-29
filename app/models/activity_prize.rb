class ActivityPrize < ActiveRecord::Base
  #validates :title, :prize, :prize_count, :prize_rate, presence: true
  FIRST, SECOND, THIRD, FOURTH, FIFTH, SIXTH = "一等奖", "二等奖", "三等奖", "四等奖", "五等奖", "六等奖"

  validates :title, presence: true, length: { maximum: 5 }, if: :can_validate?
  validates :prize, presence: true, length: { maximum: 50 }, if: :normal_prize_and_can_validate?
  validates :prize_count, numericality: {greater_than_or_equal_to: 0, only_integer: true}, if: :can_validate?
  validates :recommends_count, numericality: {greater_than_or_equal_to: 0, only_integer: true}, if: :can_validate?
  validates :time_limit, numericality: {greater_than_or_equal_to: 0, only_integer: true}, if: :can_validate?
  validates :prize_rate, numericality: {greater_than_or_equal_to: 0}, if: :can_validate_lottery?
  validates :limit_count, :day_limit_count, :people_limit_count, :people_day_limit_count, numericality: { greater_than_or_equal_to: -1, only_integer: true }, if: :can_validate?
  validates :points, numericality: {greater_than_or_equal_to: 0, only_integer: true}, if: :point_prize?
  validates :prize_value, numericality: {greater_than_or_equal_to: 1, less_than_or_equal_to: 200}, if: :redpacket_prize?

  belongs_to :activity
  has_many :activity_consumes
  has_many :consumes
  has_many :activity_prize_elements, through: :prize_elements
  has_many :prize_elements
  has_many :lottery_draws
  has_one :activity_red_packet, class_name: 'RedPacket::ActivityRedPacket'

  acts_as_enum :prize_type, in: [
    %w(normal_prize 普通奖),
    %w(point_prize 积分奖),
    %w(redpacket_prize 红包奖)
  ]

  scope :emtpy_element_ids, -> { where("length(activity_element_ids) = 0") }

  scope :active, -> { where("prize_count > 0") }

  after_destroy :change_others_prize_name, if: :slot?
  after_save :create_red_packet

  def normal_prize_and_can_validate?
    normal_prize? && can_validate?
  end

  def can_validate?
    persisted? || can_validate
  end

  def can_validate_lottery?
    can_validate? && lottery_activity?
  end

  def lottery_activity?
    activity.activity_type.gua? or activity.activity_type.wheel? or activity.activity_type.hit_egg? or activity.activity_type.slot? or activity.activity_type.wave?
  rescue
    false
  end

  def slot?
    activity.activity_type.slot?
  end

  def prize_name
    case
    when normal_prize? then attributes['prize'] 
    when point_prize?  then "#{points}积分"
    when redpacket_prize? then "#{prize_value}元红包"
    else
      attributes['prize']
    end
  end

  alias_method :prize, :prize_name

  def slot_first_id
    activity_element_ids.split(',').first rescue 0
  end

  def slot_second_id
    activity_element_ids.split(',')[1] rescue 0
  end

  def slot_last_id
    activity_element_ids.split(',').last rescue 0
  end

  def level
    activity.activity_prize_ids.index(id).to_i + 1
  end

  def sort
    activity.activity_prizes.index(self) + 1
  end

  private
    def change_others_prize_name
      if title == '四等奖'
        if prize = activity.activity_prizes.find_by_title('五等奖')
          prize.title = '四等奖'
          prize.save(validate: false)
        end
        if prize = activity.activity_prizes.find_by_title('五等奖')
          prize.title = '四等奖'
          prize.save(validate: false)
        end
      elsif title == '五等奖'
        if prize = activity.activity_prizes.find_by_title('六等奖')
          prize.title = '五等奖'
          prize.save(validate: false)
        end
      end
    end

    def create_red_packet
      if !redpacket_prize?
        activity_red_packet.destroy if activity_red_packet
        return
      end
      if activity_red_packet
        if prize_value*prize_count < 1
          activity_red_packet.destroy
          return
        end
        attr = {
          min_value: prize_value,
          max_value: prize_value,
          total_budget: prize_value*prize_count,
          budget_balance: prize_value*prize_count,
          total_amount: prize_value
        }
        activity_red_packet.update_attributes(attr)
      else 
        return if prize_value*prize_count < 1
        attr = {
            activity_prize_id: id,
            activity_id: activity.id,
            site_id: activity.try(:site).try(:id),
            payment_type_id: PaymentType::WX_REDPACKET_PAY,
            act_name: "#{activity.name}#{title}",
            nick_name: activity.site.try(:wx_mp_user).try(:name),
            send_name: activity.site.try(:wx_mp_user).try(:name),
            wishing: '恭喜发财,大吉大利',
            remark: '微枚迪技术支持',
            min_value: prize_value,
            max_value: prize_value,
            total_amount: prize_value,
            total_num: 1,
            total_budget: prize_value*prize_count,
            budget_balance: prize_value*prize_count,
            send_at: activity.try(:start_at),
            receive_type: RedPacket::RedPacket::UID
        }
        RedPacket::ActivityRedPacket.normal.create(attr)
      end
    end

end
