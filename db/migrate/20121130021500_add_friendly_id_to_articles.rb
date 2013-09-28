class AddFriendlyIdToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :slug, :string, :null => false
    add_index :articles, :slug, :unique => true
  end
end
