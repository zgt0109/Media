class RenameBookingIdToSiteIdFromBookings < ActiveRecord::Migration
  def change
  	rename_column :bookings, :booking_id, :site_id
  end
end
