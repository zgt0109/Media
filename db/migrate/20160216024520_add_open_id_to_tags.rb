class AddOpenIdToTags < ActiveRecord::Migration
  def change
    add_column :wx_user_tags,:openid,:integer ,null: false
  end
end
