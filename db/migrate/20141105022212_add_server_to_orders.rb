class AddServerToOrders < ActiveRecord::Migration

  def self.up
    change_table :sdb_b2c_orders do |t|

      t.column :serverbill ,"ENUM('0', '1')",:default=>"0"
      t.column :serverinvoice ,"ENUM('0', '1', '2','3')",:default=>"0"
      t.column :serverwarehouse ,"ENUM('0', '1')",:default=>"0"
    end
  end

  def connection
    @connection = Ecstore::Base.connection
  end
end
