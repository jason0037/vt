class CreateCustomValues < ActiveRecord::Migration
  def up
  	create_table :sdb_b2c_custom_values,:options => 'ENGINE=MyISAM DEFAULT CHARSET=utf8' do |t|
  		t.integer :order_id,:limit=>8
            t.integer :member_id
            t.integer :product_id
  		t.integer :spec_item_id
            t.string :name
  		t.string :value
  		t.timestamps
  	end
  end

  def down
  	drop_table :sdb_b2c_custom_values
  end

  def connection
  	@connection = Ecstore::Base.connection
  end
end
