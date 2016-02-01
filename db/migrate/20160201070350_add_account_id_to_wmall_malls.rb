class AddAccountIdToWmallMalls < ActiveRecord::Migration
  def change
    add_column :wmall_malls, :account_id, :integer, after: :site_id
  end
end
