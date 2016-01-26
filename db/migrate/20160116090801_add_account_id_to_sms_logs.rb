class AddAccountIdToSmsLogs < ActiveRecord::Migration
  def change
    add_column :sms_logs, :account_id, :integer, default: 0, after: :id

    add_index :sms_logs, [:account_id, :date]
  end
end
