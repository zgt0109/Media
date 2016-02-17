class CreateWxUserGroups < ActiveRecord::Migration
  def change
    create_table :wx_user_groups do |t|
      t.string  :name ,null:false
      t.integer :openid, null:false
      t.integer :count ,default:0
      t.integer :groupid ,null:false
      t.timestamps
    end
  end
end
