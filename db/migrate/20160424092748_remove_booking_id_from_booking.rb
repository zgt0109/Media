class RemoveBookingIdFromBooking < ActiveRecord::Migration
  def up
    remove_column :bookings, :booking_id
  end

  def down
    add_column :bookings, :booking_id, :integer, null: true
  end
end
