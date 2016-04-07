class AddMetadataToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :metadata, :text, after: :status
  end
end
