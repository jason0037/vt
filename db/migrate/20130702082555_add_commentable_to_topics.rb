class AddCommentableToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :commentable, :boolean,:default=>false
  end
end
