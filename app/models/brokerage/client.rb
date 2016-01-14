class Brokerage::Client < ActiveRecord::Base
  belongs_to :broker, counter_cache: true
  belongs_to :commission_type, class_name: '::Brokerage::CommissionType'
  has_many :client_changes
  has_many :changed_commission_types, through: :client_changes, source: :commission_type, order: "brokerage_commission_types.#{Brokerage::CommissionType::SORT_FIELD} ASC"

  attr_accessor :change_commission

  validates :name, :mobile, presence: true
  validates :mobile, mobile: true
  validate :uniqueness_of_mobile

  before_validation :init_commission_type
  validate :validate_commission_type
  after_create :create_client_change

  scope :client_type_count, ->(mission_type) { joins(:commission_type).where("brokerage_commission_types.mission_type = ?", mission_type) if mission_type }

  def computed_commission
    # TODO do real compution by commission_type.commission_value and last_client_change.value
    commission_type.commission_value
  end

  def last_changed_commission_type
    @last_changed_commission_type ||= changed_commission_types.last
  end

  def last_changed_commission_type_id
    @last_changed_commission_type_id ||= last_changed_commission_type.try(:id).to_i
  end

  def higher_commission_types
    @higher_commission_types ||= broker.site.brokerage_commission_types.enabled.higher_than(last_changed_commission_type)
  end

  #得到客户要修改的新状态，计算新状态对应的金额，将客户状态更新
  #新生成一条client_changes记录，其中commission_type为修改后的客户新状态，commission为客户新状态对应的金额
  #增加对应经纪人的unsettled_commission(未结算佣金)
  def change_commission_type(commission_type_id, client_commission)
    transaction do
      new_commission_type = broker.site.brokerage_commission_types.find commission_type_id
      computed_commission = new_commission_type.get_commission(client_commission)
      old_commission_type = commission_type

      update_attributes!(commission_type: new_commission_type)
      client_changes.create!(
          old_commission_type: old_commission_type,
          commission_type:     new_commission_type,
          commission:          computed_commission
      )
      broker.increment! :unsettled_commission, computed_commission
    end
  end

  private
    def init_commission_type
      self.commission_type ||= broker.site.brokerage_commission_types.new_client.first
    end

    def validate_commission_type
      return true if commission_type > last_changed_commission_type
      higher_mission_type_names = higher_commission_types.map(&:mission_type_name)
      unless higher_mission_type_names.empty?
        errors.add(:base, "状态只能修改成 #{higher_mission_type_names.join('、')}")
      else
        errors.add(:base, "此状态已不可修改")
      end
    end

    def create_client_change
      client_changes.create!(
          commission_type:     commission_type,
          commission:          commission_type.commission_value
      )
      broker.increment!(:unsettled_commission, commission_type.commission_value)
    end

    def uniqueness_of_mobile
      return if errors.has_key?(:mobile)
      if broker.site.brokerage_clients.where('brokerage_clients.mobile = ? and brokerage_clients.id != ?', mobile, id.to_i).exists?
        errors.add(:mobile, '已经被推荐过')
      end
    end
end
