class AddColumnMerchantUrlToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :merchant_url, :string, after: :callback_url
  end
end
