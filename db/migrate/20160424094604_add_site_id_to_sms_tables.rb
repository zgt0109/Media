class AddSiteIdToSmsTables < ActiveRecord::Migration
  def change
    add_column :sms_expenses, :site_id, :integer, after: :account_id
    add_column :sms_logs, :site_id, :integer, after: :account_id
    add_column :sms_orders, :site_id, :integer, after: :account_id
  end
end
