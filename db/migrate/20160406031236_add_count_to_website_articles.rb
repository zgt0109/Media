class AddCountToWebsiteArticles < ActiveRecord::Migration
  def change
    add_column :website_articles, :view_count, :integer, after: :is_top
    add_column :website_articles, :likes_count, :integer, after: :view_count
    add_column :website_articles, :comments_count, :integer, after: :likes_count
  end
end
