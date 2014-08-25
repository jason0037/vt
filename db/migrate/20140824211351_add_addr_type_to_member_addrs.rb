class AddAddrTypeToMemberAddrs < ActiveRecord::Migration
  def change
    add_column :sdb_b2c_member_addrs, :addr_type, :int

    ### 0是收货，1是发货
  end

  def connection
    @connection = Ecstore::Base.connection
  end
end