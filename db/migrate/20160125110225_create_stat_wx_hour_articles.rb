class CreateStatWxHourArticles < ActiveRecord::Migration
  def change
    create_table :stat_wx_hour_articles do |t|
      t.string :openid, null: false
      t.date :ref_date, null: false, default: 0
      t.integer :ref_hour ,null:false ,default:0
      t.string :msgid ,null: false
      t.string :title,null: false
      t.integer :int_page_read_user,null: false, default: 0
      t.integer :int_page_read_count,null: false, default: 0
      t.integer :ori_page_read_user,null: false, default: 0
      t.integer :ori_page_read_count,null: false, default: 0
      t.integer :share_scene,null: false, default: 0
      t.integer :share_user,null: false, default: 0
      t.integer :share_count,null: false, default: 0
      t.integer :add_to_fav_user,null: false, default: 0
      t.integer :add_to_fav_count,null: false, default: 0
      t.integer :target_user,null: false, default: 0
      t.integer :user_source,null: false, default: 0
      t.datetime :updated_at
    end
  end
end
