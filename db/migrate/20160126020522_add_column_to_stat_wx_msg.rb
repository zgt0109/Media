class AddColumnToStatWxMsg < ActiveRecord::Migration
  def change

    add_column :stat_wx_msgs,:user_source,:integer,default: 0,null: false
  end
end
