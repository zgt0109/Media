class AddAccountCategoryIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :account_category_id, :integer, after: :account_type
  end
end
