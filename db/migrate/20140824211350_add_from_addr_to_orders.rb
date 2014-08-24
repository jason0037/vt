class AddFromAddrToOrders < ActiveRecord::Migration
  def change
    add_column :sdb_b2c_orders, :from_addr, :string
  end
  def connection
    @connection = Ecstore::Base.connection
  end
end