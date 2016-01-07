class Aid::Rule
  # Model Object without Database persist
  # Apply for rule of activity
  extend  ActiveModel::Naming
  extend  ActiveModel::Callbacks
  include ActiveModel::Conversion
  include ActiveModel::Validations

  RANKING_LIST_LIMIT        = 50
  AID_FRIENDS_LIMIT         = 50

  PRIZE_DEFAULT_MODEL       =  0x00
  PRIZE_USER_MOBILE_MASK    =  0x01
  PRIZE_USER_NAME_MASK      =  0x02
  PRIZE_PASSWORD_MASK       =  0x04

  MODEL_RANDOM              =  0x01
  MODEL_FIXED               =  0x02

  SMS_VERIFICATION_TRUE     = 0x01
  SMS_VERIFICATION_FALSE    = 0x00

  ATTR_METHODS = [:model, :base_points, :is_sms_validation, :password, :banner_pic_url, :prize_model]
   
  ATTR_METHODS.each do |method|
    attr_accessor method 
  end

  validates_presence_of     :model, :base_points
  validates_numericality_of :base_points, greater_than: 0
  validates_numericality_of :base_points, less_than_or_equal_to: 1000
  #validates_length_of       :password, minimum: 6, maxmum: 10 

  def model_random?
    model.to_i == MODEL_RANDOM
  end

  def model_fixed?
    model.to_i == MODEL_FIXED
  end

  def initialize(attrs = {})
    update_attributes attrs
  end

  def update_attributes(attrs = {})
    return unless attrs.present?

    ATTR_METHODS.each do |method|
      self.public_send(method.to_s + '=', attrs[method])
    end
  end
 
  def persisted?
    false
  end
end
