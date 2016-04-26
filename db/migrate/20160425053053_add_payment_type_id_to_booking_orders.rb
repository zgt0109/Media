class AddPaymentTypeIdToBookingOrders < ActiveRecord::Migration
  def change
    add_column :booking_orders, :payment_type_id, :integer, after: :user_id
  end
end
