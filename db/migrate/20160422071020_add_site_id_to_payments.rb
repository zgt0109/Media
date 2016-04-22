class AddSiteIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :site_id, :integer, after: :account_id
  end
end
