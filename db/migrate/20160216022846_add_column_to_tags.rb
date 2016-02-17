class AddColumnToTags < ActiveRecord::Migration
  def change

    add_column :wx_user_tags, :groupid ,:integer , null: false
  end
end
