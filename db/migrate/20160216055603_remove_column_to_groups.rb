class RemoveColumnToGroups < ActiveRecord::Migration
  def up
  end

  def down

    remove_column :wx_user_groups ,:openid
  end
end
