class AddAuthorToMaterial < ActiveRecord::Migration
  def change
    add_column :materials, :author, :string, limit: 50, after: :title
  end
end
