# == Schema Information
#
# Table name: wedding_guests
#
#  id           :integer          not null, primary key
#  wedding_id   :integer          not null
#  username     :string(255)      not null
#  phone        :string(255)      not null
#  people_count :integer          default(1), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  wx_user_id   :integer          not null
#

class WeddingGuest < ActiveRecord::Base
  belongs_to :wedding
 # attr_accessible :people_count, :phone, :username

  def self.get_conditions params
    conn = [[]]
    if params[:username].present?
      conn[0] << "username like ?"
      conn << "%#{params[:username]}%"
    end

    if params[:phone].present?
      conn[0] << "phone like ?"
      conn << "%#{params[:phone]}%"
    end
    conn[0] = conn[0].join(' and ')
    conn
  end
end
