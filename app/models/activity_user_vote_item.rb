# == Schema Information
#
# Table name: activity_user_vote_items
#
#  id                    :integer          not null, primary key
#  activity_id           :integer
#  activity_vote_item_id :integer
#  wx_user_id            :integer
#  mobile                :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  name                  :string(255)      not null
#

class ActivityUserVoteItem < ActiveRecord::Base
  belongs_to :activity
  belongs_to :activity_vote_item, counter_cache: true
  belongs_to :wx_user
  belongs_to :activity_user

  after_commit :update_activity_user_vote_item_ids, on: :create

  def self.get_conditions params
    conn = [[]]
    if params[:activity_ids].present?
      conn[0] << "activity_id in (?)"
      conn << params[:activity_ids]
    end

    if params[:created_at_start].present?
      conn[0] << "created_at >= ?"
      conn << params[:created_at_start]
    end

    if params[:created_at_end].present?
      conn[0] << "created_at <= ?"
      conn << params[:created_at_end]
    end
    conn[0] = conn[0].join(" and ")
    conn
  end

  private
    def update_activity_user_vote_item_ids
      return if activity_user_id.blank?
      activity_user.update_column :vote_item_ids, activity_user.activity_user_vote_items.pluck(:activity_vote_item_id).join(',') if activity_user
    end
end
