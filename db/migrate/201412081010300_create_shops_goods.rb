class CreateShopsGoods < ActiveRecord::Migration
  def change

    create_table :shops_goods do |t|
     t.integer :shop_id
     t.string :goods_id
     t.string :down_time


      t.timestamps
    end
  end
  def connection
    @connection = Ecstore::Base.connection
  end

end
