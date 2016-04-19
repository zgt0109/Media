class AddCountToWebsiteMenu < ActiveRecord::Migration
  def change
    add_column :website_menus, :view_count, :integer, default: 0, null: false, after: :subtitle
    add_column :website_menus, :likes_count, :integer, default: 0, null: false, after: :view_count
    add_column :website_menus, :comments_count, :integer, default: 0, null: false, after: :likes_count
  end
end
