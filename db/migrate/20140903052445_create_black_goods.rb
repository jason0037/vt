class CreateBlackGoods < ActiveRecord::Migration
  def change
    create_table :sdb_b2c_black_good do |t|
      t.string :name
      t.string :weight
      t.integer :uptime
      t.integer :downtime
      t.string :ship_id
      t.integer :status
      t.integer :receive
      t.integer :type_id
      t.integer :cat_id
      t.float :price
      t.string :desc

      t.timestamps
    end
  end
  def connection
    @connection =  Ecstore::Base.connection
  end
end
