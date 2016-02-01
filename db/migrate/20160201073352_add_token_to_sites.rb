class AddTokenToSites < ActiveRecord::Migration
  def change
    add_column :sites, :token, :string, after: :status
  end
end
