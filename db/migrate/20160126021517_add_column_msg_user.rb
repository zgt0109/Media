class AddColumnMsgUser < ActiveRecord::Migration
  def change

    add_column :stat_wx_msgs ,:msg_user ,:integer,default: 0,null: false
  end
end
