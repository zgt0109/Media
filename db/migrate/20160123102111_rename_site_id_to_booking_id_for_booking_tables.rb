class RenameSiteIdToBookingIdForBookingTables < ActiveRecord::Migration
  def change
    remove_index :booking_ads, :site_id
    remove_index :booking_categories, :site_id
    remove_index :booking_items, :site_id
    remove_index :booking_orders, :site_id

    rename_column :booking_ads, :site_id, :booking_id
    rename_column :booking_categories, :site_id, :booking_id
    rename_column :booking_items, :site_id, :booking_id
    rename_column :booking_orders, :site_id, :booking_id

    add_index :booking_ads, :booking_id
    add_index :booking_categories, :booking_id
    add_index :booking_items, :booking_id
    add_index :booking_orders, :booking_id
  end
end
