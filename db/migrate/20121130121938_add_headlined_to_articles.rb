class AddHeadlinedToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :headlined, :boolean, :default => false
  end
end
