class RenameAccountPasswordsToUserPasswords < ActiveRecord::Migration
  def change
    rename_table :account_passwords, :user_passwords
    rename_column :user_passwords, :account_id, :site_id
  end
end
