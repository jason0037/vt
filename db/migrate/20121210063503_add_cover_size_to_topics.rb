class AddCoverSizeToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :cover_size, :string, :default => "big" # big, normal, small
  end
end
