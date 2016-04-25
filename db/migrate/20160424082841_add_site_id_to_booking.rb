class AddSiteIdToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :site_id, :integer, after: :booking_id
  end
end
