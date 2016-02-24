class CreateWxUserGroups < ActiveRecord::Migration
  def change
    create_table :wx_user_groups do |t|
      t.integer :wx_mp_user_id, null: false
      t.integer :groupid, null: false
      t.string  :name, null: false
      t.integer :count, default: 0
      t.timestamps
    end
  end
end
