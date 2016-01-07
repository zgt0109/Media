# == Schema Information
#
# Table name: wedding_wishes
#
#  id         :integer          not null, primary key
#  wedding_id :integer          not null
#  username   :string(255)      not null
#  gender     :integer          default(1), not null
#  content    :text             default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WeddingWish < ActiveRecord::Base
  belongs_to :wedding
  #attr_accessible :content, :gender, :username


  def self.get_conditions params
    conn = [[]]
    if params[:username].present?
      conn[0] << "username like ?"
      conn << "%#{params[:username]}%"
    end

    if params[:mobile].present?
      conn[0] << "mobile like ?"
      conn << "%#{params[:mobile]}%"
    end
    conn[0] = conn[0].join(' and ')
    conn
  end
end
