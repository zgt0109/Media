class AddBookingTypeToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :booking_type, :integer, null: false, after: :name
  end
end
