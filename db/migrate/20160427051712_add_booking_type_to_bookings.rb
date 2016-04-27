class AddBookingTypeToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :booking_type, :integer, default: 1, null: false, after: :name
  end
end
