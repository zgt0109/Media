class AddSmsColumnsToSites < ActiveRecord::Migration
  def change
    add_column :sites, :is_open_sms, :boolean, default: false, null: false, after: :status
    add_column :sites, :pay_sms_count, :integer, default: 0, null: false, after: :is_open_sms
    add_column :sites, :free_sms_count, :integer, default: 0, null: false, after: :pay_sms_count
  end
end
