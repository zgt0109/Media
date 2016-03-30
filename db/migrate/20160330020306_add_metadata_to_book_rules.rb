class AddMetadataToBookRules < ActiveRecord::Migration
  def change
    add_column :book_rules, :metadata, :text
  end
end
