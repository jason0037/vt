class CreateImodecEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.text :body
      t.string :slug
      t.timestamps
    end

    add_index :events, :slug, :unique => true
  end
end