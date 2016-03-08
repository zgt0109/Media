class AddAddressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :address, :string, after: :gender
  end
end
