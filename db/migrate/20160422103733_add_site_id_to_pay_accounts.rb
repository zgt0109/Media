class AddSiteIdToPayAccounts < ActiveRecord::Migration
  def change
    add_column :pay_accounts, :site_id, :integer, after: :account_id
  end
end
