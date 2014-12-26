class CreateAdverts < ActiveRecord::Migration
  def change
    create_table :sdb_cheuks_adverts do |t|
      t.string :advert_slug
      t.text :body
      t.string :title
      t.integer :cat_id
      t.timestamps
    end
  end

  def down
    drop_table :sdb_cheuks_adverts
  end

  def connection
    @connection =  Ecstore::Base.connection
  end

end
