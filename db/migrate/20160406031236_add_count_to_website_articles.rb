class AddCountToWebsiteArticles < ActiveRecord::Migration
  def change
    add_column :website_articles, :view_count, :integer, default: 0, null: false, after: :is_top
    add_column :website_articles, :likes_count, :integer, default: 0, null: false, after: :view_count
    add_column :website_articles, :comments_count, :integer, default: 0, null: false, after: :likes_count
  end
end
