class AddPvCountToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :pv_count, :integer, null: false, default: 0, after: :status, comment: '访问量'
  end
end
