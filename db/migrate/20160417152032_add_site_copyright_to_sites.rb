class AddSiteCopyrightToSites < ActiveRecord::Migration
  def change
    add_column :sites, :show_copyright, :boolean, default: true, null: false, after: :status
    add_column :sites, :site_copyright_id, :integer, after: :show_copyright
  end
end
