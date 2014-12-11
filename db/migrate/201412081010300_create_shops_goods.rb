<<<<<<< HEAD
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
=======
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
>>>>>>> 896dafebe2ab348b1366f1ef9b4dd0434eaf2667
