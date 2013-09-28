class CreateGoodsSpecItems < ActiveRecord::Migration
  def up
  	create_table :sdb_b2c_goods_spec_items,:options => 'ENGINE=MyISAM DEFAULT CHARSET=utf8' do |t|
  		t.integer :goods_id
  		t.integer :spec_item_id
            t.integer :spec_value_id
  		t.string :fixed_value
  		t.string :max_value
  		t.string :min_value
  	end
  end

  def down
  	drop_table :sdb_b2c_goods_spec_items
  end

  def connection
  	@connection = Ecstore::Base.connection
  end
end
