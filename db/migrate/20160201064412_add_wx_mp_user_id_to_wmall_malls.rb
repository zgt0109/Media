class AddWxMpUserIdToWmallMalls < ActiveRecord::Migration
  def change
    add_column :wmall_malls, :wx_mp_user_id, :integer, after: :site_id
  end
end
