class DelColumnToGroups < ActiveRecord::Migration
  def up
    remove_column :wx_user_groups ,:openid
  end

  def down
  end
end
