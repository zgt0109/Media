class MerchantApp::OrdersController < Api::V1::BaseController
  layout 'merchant_app'

  #/merchant_app/orders/plot_orders?role=account&&role_id=10041&token=tXVwisFtTPhR0mk0N_GTQyWAXo3_2HIy0wx46zIFRkJw-xEP6VDqGkYtVC_4iqglbOBiO0g60C0BxoR9
  def plot_orders;end

  def plot_order_detail;end

  def car_orders;end

  def car_order_detail;end

  def reservation_orders;end

  def reservation_order_detail;end

  def shop_orders;end

  def shop_order_detail;end

  def shop_table_orders;end

  def shop_table_order_detail;end

  def gov_orders;end

  def gov_order_detail;end

end
