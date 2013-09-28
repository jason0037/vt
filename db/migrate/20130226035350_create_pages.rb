class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.text :body
      t.integer :topic_id
      # t.integer :page_num

      t.timestamps
    end
  end
end
