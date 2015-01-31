class CreateShopsGoods < ActiveRecord::Migration
  def change

    create_table :shops_goods do |t|
     t.integer :shop_id
     t.string :goods_id
     t.integer :uptime ##上架时间
     t.column :good_status ,"ENUM('0', '1')",:default=>"0"   ###1上架
      t.integer :supplier_id
      t.timestamps
    end
  end
  def connection
    @connection = Ecstore::Base.connection
  end

end
