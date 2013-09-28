class AddPartPayToOrders < ActiveRecord::Migration
  def change
    add_column :sdb_b2c_orders, :part_pay, :decimal,:precision=>10,:scale=>3, :default => 0.000
  end

  def connection
  	@connection = Ecstore::Base.connection
  end
  
end
