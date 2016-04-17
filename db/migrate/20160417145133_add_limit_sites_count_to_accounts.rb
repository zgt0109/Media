class AddLimitSitesCountToAccounts < ActiveRecord::Migration
  def change
  	add_column :accounts, :limit_sites_count, :integer, default: 1, null: false, after: :free_sms_count
  end
end
