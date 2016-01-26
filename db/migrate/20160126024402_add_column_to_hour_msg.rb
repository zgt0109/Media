class AddColumnToHourMsg < ActiveRecord::Migration
  def change
    add_column :stat_wx_hour_msgs ,:msg_user ,:integer,default: 0,null: false
    add_column :stat_wx_hour_msgs,:user_source,:integer,default: 0,null: false
  end
end
