module Concerns::VipGivenGroupable
  extend ActiveSupport::Concern

  included do
    delegate :vip_users, to: :vip_card
    belongs_to :given_group, polymorphic: true

    enum_attr :given_group_type, in: [
      %w(give_to_vip_group VipGroup 会员分组),
      %w(give_to_vip_grade VipGrade 会员等级)
    ]

    validates :vip_card, presence: true
    validates :given_group_type, inclusion: {in: const_get('GIVEN_GROUP_TYPES').keys, message: '必须是“会员分组”或“会员等级”'}
    validate :given_group_id_must_be_valid
  end

  def group_receivers
    @group_receivers ||= if given_group_id == -1
      vip_users
    elsif give_to_vip_group?
      return vip_users.where(vip_group_id: nil) if given_group_id == -2
      vip_users.where(vip_group_id: given_group_id)
    elsif give_to_vip_grade?
      vip_users.where(vip_grade_id: given_group_id)
    end
  end

  private
  def given_group_id_must_be_valid
    return true if [nil, -1, -2].include?(given_group_id) || !vip_card

    if give_to_vip_group?
      unless vip_card.vip_groups.where(id: given_group_id).exists?
        group_names = vip_card.vip_groups.pluck(:name)
        errors.add(:given_group_id, "会员分组必须属于 #{group_names.join('、 ')}")
      end
    elsif give_to_vip_grade?
      unless vip_card.vip_grades.where(id: given_group_id).exists?
        group_names = vip_card.vip_grades.pluck(:name)
        errors.add(:given_grade_id, "会员等级必须属于 #{group_names.join('、 ')}")
      end
    end
  end
end
