class Mobile::CarAssistantsController < Mobile::BaseController
  layout 'mobile/car'
  before_filter :get_shop

  def index
    @assistants = Assistant.enabled.cars.order('sort ASC')
    @assistant_ids = @supplier.assistants_accounts.collect(&:assistant_id)
  end

  private

  def get_shop
    @car_shop = @supplier.car_shop
    @car_brand = @car_shop.car_brand
    @activity = @car_shop.car_activity_notices.assistant.first.activity
    if @supplier.website.try(:website_menus).to_a.select{|f| f.activity?}.flatten.select{|f| f.menuable_id == @activity.id}
      @url = mobile_root_url(supplier_id: @supplier.id)
    else
      @url = mobile_car_assistants_url(supplier_id: @supplier.id, aid: @activity.id)
    end
  end

end