class AddPositionIdToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :position_id, :integer
  end
end
