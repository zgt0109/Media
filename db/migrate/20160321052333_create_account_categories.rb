class CreateAccountCategories < ActiveRecord::Migration
  def change
    create_table "account_categories" do |t|
      t.integer  "parent_id",               :default => 0, :null => false
      t.string   "name",                                   :null => false
      t.integer  "sort",                    :default => 0, :null => false
      t.integer  "status",     :limit => 1, :default => 1, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end