class CreateShops < ActiveRecord::Migration
  def change

    create_table :shops do |t|
     t.integer :shop_id
     t.string :shop_name
     t.string :shop_tel
     t.string :shop_email
     t.string :shop_logo
     t.string :shop_wx
     t.string :shop_intro
      t.integer :shop_publish
      t.timestamps
    end
  end
  def connection
    @connection = Ecstore::Base.connection
  end

end

