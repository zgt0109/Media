class CreateStatWxUsers < ActiveRecord::Migration
  def change
    create_table :stat_wx_users do |t|
      t.integer :openid, null:false
      t.date  :ref_date , null:false
      t.integer :cumulate_user, null:false, default:0
      t.integer :cancel_user, null:false, default: 0
      t.integer :new_user, null:false, default: 0
      t.integer :user_source, null:false, default: 0
      t.dateime :updated_at
    end
  end
end
