class AddAddrTypeToMemberAddrs < ActiveRecord::Migration
  def change
    add_column :sdb_b2c_member_addrs, :addr_type, :int
  end
  def connection
    @connection = Ecstore::Base.connection
  end
end