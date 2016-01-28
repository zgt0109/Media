class CreateStatWxHourMsgs < ActiveRecord::Migration
  def change
    create_table :stat_wx_hour_msgs do |t|
      t.integer :openid,null:false
      t.date :ref_date,null:false
      t.integer :ref_hour,null:false
      t.integer :msg_type,null:false ,default:0
      t.integer :msg_count,null:false ,default:0
      t.integer :count_interval,null:false ,default:0
      t.integer :int_page_read_count,null:false ,default:0
      t.integer :ori_page_read_user,null:false ,default:0
      t.timestamps
    end
  end
end
