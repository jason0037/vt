class AddRefIdToCart < ActiveRecord::Migration
  def self.up
    change_table :sdb_b2c_cart_objects do |t|
      t.integer :ref_id   ###团购

    end
  end

  def connection
    @connection = Ecstore::Base.connection
  end


  end
