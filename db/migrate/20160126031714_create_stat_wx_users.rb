class CreateStatWxUsers < ActiveRecord::Migration
  def change
    create_table :stat_wx_users do |t|
      t.date  :ref_date ,null:false
      t.string :openid,null:false
      t.integer :cumulate_user ,null:false ,default:0
      t.integer :cancel_user,null:false ,default: 0
      t.integer :new_user,null:false ,default: 0
      t.integer :user_source,null:false ,default: 0
      t.timestamps
    end
  end
end
