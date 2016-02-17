class CreateWxUserTags < ActiveRecord::Migration
  def change
    create_table :wx_user_tags do |t|
      t.string :name ,null:false
      t.integer :openid, null:false
      t.integer :count ,default:0
      t.timestamps
    end
  end
end
