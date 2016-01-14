class RedPacket::Release < ActiveRecord::Base
  belongs_to :activity
  belongs_to :user
  belongs_to :activity_user
  has_one :consume, as: :consumable

  accepts_nested_attributes_for :activity_user

  delegate :name, to: :activity, allow_nil: true

  scope :used, -> { where('used_at IS NOT NULL') }
  scope :unused, -> { where(used_at: nil) }

  before_create :generate_award_amount
  after_create :create_release_consume

  def used!
    update_attributes! used_at: Time.now
  end

  def setting
    activity.activityable
  end

  private
    def generate_award_amount
      self.award_amount = setting.generate_award_amount
    end

    def create_release_consume
      self.create_consume(user_id: user.id, mobile: activity_user.mobile)
    end
end
