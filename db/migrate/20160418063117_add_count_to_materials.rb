class AddCountToMaterials < ActiveRecord::Migration
  def change
    add_column :materials, :view_count, :integer, default: 0, null: false, after: :sort
    add_column :materials, :likes_count, :integer, default: 0, null: false, after: :view_count
    add_column :materials, :comments_count, :integer, default: 0, null: false, after: :likes_count
  end
end
