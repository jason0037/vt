class AddShopStatusToGoods < ActiveRecord::Migration
   def self.up
    change_table :sdb_b2c_goods do |t|
      t.column :shopstatus ,"ENUM('true','false')",:default=>"true"
      end
  end

  def connection
    @connection = Ecstore::Base.connection
  end
end
