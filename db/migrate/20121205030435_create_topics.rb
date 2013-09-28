class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :title
      t.text :body
      t.integer :user_id
      t.datetime :published_at
      t.boolean :published, :default => false
      t.string :slug
      t.text :summary
      t.string :cover_file_name
      t.string :cover_content_type
      t.integer :cover_file_size
      t.datetime :cover_updated_at
      t.integer :position_id

      t.timestamps
    end

    add_index :topics, :slug, :unique => true
  end
end
