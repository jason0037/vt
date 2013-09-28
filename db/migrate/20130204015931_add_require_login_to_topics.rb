class AddRequireLoginToTopics < ActiveRecord::Migration
  def up
  	add_column :topics, :require_login, :boolean,:default=>true
  end

  def down
  	remove_column :topics, :require_login
  end
end
