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
