class ChangeColumnToWxData < ActiveRecord::Migration
  def change

    change_column :stat_wx_users,:openid,:integer,null: false
  end
end
