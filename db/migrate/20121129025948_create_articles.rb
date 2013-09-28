class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body
      t.integer :user_id
      t.datetime :published_at
      t.boolean :published, :default => false

      t.timestamps
    end
  end
end
