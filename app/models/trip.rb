class Trip < ActiveRecord::Base

  validates :name, presence: true

  belongs_to :site
  belongs_to :wx_mp_user

  has_many :trip_orders, dependent: :destroy
  has_many :trip_ads, dependent: :destroy
  has_many :trip_tickets, dependent: :destroy

  has_one :activity, as: :activityable, dependent: :destroy

  accepts_nested_attributes_for :activity

  # TODO
  def save_trip_act(params)
  	# activity = Activity.new(params[:activity])
  	# if activity.save
	  	self.name = params[:trip][:name]
	  	self.logo = params[:trip][:activity_attributes][:pic]
	  	self.description = params[:trip][:activity_attributes][:summary]
	  	self.save
      # Rails.logger.info "==#{self.name}===#{self.logo}====#{self.description}===="
  	# end
  end

end
