class AddCategoryIdToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :category_id, :integer
  end
end
