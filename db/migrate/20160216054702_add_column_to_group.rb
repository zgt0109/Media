class AddColumnToGroup < ActiveRecord::Migration
  def change
    add_column :wx_user_groups ,:wx_mp_user_id,:integer ,null:false
  end
end
