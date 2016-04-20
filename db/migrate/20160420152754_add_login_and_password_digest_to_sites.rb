class AddLoginAndPasswordDigestToSites < ActiveRecord::Migration
  def change
    add_column :sites, :login, :string, after: :name
    add_column :sites, :password_digest, :string, after: :login
  end
end
