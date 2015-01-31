class AddRefIdToOrdeItem < ActiveRecord::Migration
  def self.up
    change_table :sdb_b2c_order_items do |t|
      t.integer :ref_id   ###团购

    end
  end

  def connection
    @connection = Ecstore::Base.connection
  end

end
