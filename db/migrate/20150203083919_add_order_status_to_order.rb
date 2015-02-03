class AddOrderStatusToOrder < ActiveRecord::Migration
  def self.up
    change_table :sdb_b2c_orders do |t|
    t.column :orderstatus ,"ENUM('true','false')",:default=>"true"
    end
  end
  def connection
    @connection = Ecstore::Base.connection
  end

end
