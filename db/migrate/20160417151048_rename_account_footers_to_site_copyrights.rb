class RenameAccountFootersToSiteCopyrights < ActiveRecord::Migration
  def change
    rename_table :account_footers, :site_copyrights
    rename_column :site_copyrights, :account_id, :site_id
  end
end
