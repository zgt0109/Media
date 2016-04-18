class AddCountToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :view_count, :integer, default: 0, null: false, after: :attention_tips
    add_column :websites, :likes_count, :integer, default: 0, null: false, after: :view_count
    add_column :websites, :comments_count, :integer, default: 0, null: false, after: :likes_count
  end
end
