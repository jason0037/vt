class CreateOrderCustoms < ActiveRecord::Migration
  def up
  	create_table :sdb_b2c_order_customs,:options => 'ENGINE=MyISAM DEFAULT CHARSET=utf8' do |t|
  		t.integer :order_id
  		t.integer :member_id
  		t.integer :product_id
  		
  		t.timestamps
  	end
  end

  def down
  	drop_table :sdb_b2c_order_customs
  end

  def connection
  	@connection = Ecstore::Base.connection
  end

end
