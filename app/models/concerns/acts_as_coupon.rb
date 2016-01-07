module Concerns::ActsAsCoupon
  extend ActiveSupport::Concern
  included do
    validates :consume_day_allow_count, numericality: { greater_than: 0, only_integer: true, allow_blank: true }, if: :can_validate_coupon?

    validate :validate_coupon_day_allow_count, if: :can_validate_coupon?
    validate :validate_get_limit_count, if: :can_validate_coupon?

    def can_validate_coupon?
      can_validate? && old_coupon?
    end

    def validate_coupon_day_allow_count
      if consume_day_allow_count.to_i > coupon_count
        errors.add(:consume_day_allow_count, "不能大于优惠券总数")
      end
    end

    def validate_get_limit_count
      if get_limit_count > coupon_count
        errors.add(:get_limit_count, "不能大于优惠券总数")
      end
    end

  end
end
